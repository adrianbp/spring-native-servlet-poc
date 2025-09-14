#!/bin/bash

echo "🔄 Reconfigurando GitHub ARM Runner"
echo "=================================="

# Obter IP da instância
INSTANCE_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=*github-runner*" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].PublicIpAddress' --output text)

if [ -z "$INSTANCE_IP" ] || [ "$INSTANCE_IP" == "None" ]; then
    echo "❌ Instância não encontrada ou não está rodando."
    echo "🔍 Verificando todas as instâncias..."
    aws ec2 describe-instances --filters "Name=tag:Name,Values=*github-runner*" --query 'Reservations[].Instances[].{InstanceId:InstanceId,Name:Tags[?Key==`Name`].Value|[0],State:State.Name,PublicIP:PublicIpAddress}' --output table
    exit 1
fi

echo "🔍 Instância encontrada: $INSTANCE_IP"
echo ""

# Verificar se consegue conectar
echo "📡 Testando conexão SSH..."
if ! ssh -o ConnectTimeout=10 -i ~/.ssh/id_rsa ubuntu@$INSTANCE_IP "echo 'Conexão OK'" 2>/dev/null; then
    echo "❌ Não foi possível conectar via SSH."
    echo "🔧 Possíveis soluções:"
    echo "1. Aguarde alguns minutos se a instância acabou de ser criada"
    echo "2. Verifique se o Security Group permite SSH na porta 22"
    echo "3. Verifique se a chave ~/.ssh/id_rsa está correta"
    exit 1
fi

echo "✅ Conexão SSH OK"
echo ""

# Gerar novo token do GitHub
echo "🔑 Você precisa de um novo token do GitHub para o runner."
echo "📝 Vá para: https://github.com/adrianbp/spring-native-servlet-poc/settings/actions/runners"
echo "🖱️  Clique em 'New self-hosted runner' → Linux → ARM64"
echo "📋 Copie o token que aparece no comando de configuração"
echo ""

read -p "🔑 Cole o token do GitHub aqui: " GITHUB_TOKEN

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Token não pode estar vazio!"
    exit 1
fi

echo ""
echo "🚀 Reconfigurando runner na instância $INSTANCE_IP..."

# Script de reconfiguração remota
ssh -i ~/.ssh/id_rsa ubuntu@$INSTANCE_IP << EOF
echo "� Instalando bibliotecas necessárias para compilação nativa..."
sudo apt-get update
sudo apt-get install -y build-essential zlib1g-dev libz-dev libstdc++-11-dev libc6-dev libgtk2.0-dev libxtst-dev

echo "�🔄 Parando runner atual..."
sudo systemctl stop actions.runner.* || true

echo "🗑️ Removendo configuração antiga..."
cd /home/ubuntu/actions-runner
sudo ./svc.sh uninstall || true
./config.sh remove --unattended || true

echo "🔧 Configurando novo runner..."
./config.sh --url https://github.com/adrianbp/spring-native-servlet-poc --token $GITHUB_TOKEN --name graviton-runner --labels self-hosted,Linux,ARM64,graviton --work _work --replace

echo "🚀 Instalando e iniciando serviço..."
sudo ./svc.sh install ubuntu
sudo ./svc.sh start

echo "📊 Status do serviço:"
sudo systemctl status actions.runner.adrianbp-spring-native-servlet-poc.graviton-runner

# Verificar versões das ferramentas instaladas
echo ""
echo "📋 Versões das ferramentas instaladas:"
echo "GraalVM: \$(java -version 2>&1 | head -1)"
echo "Maven: \$(mvn --version 2>&1 | head -1)"
echo "GCC: \$(gcc --version 2>&1 | head -1)"
echo "Docker: \$(docker --version 2>&1)"
echo "zlib: \$(dpkg -l | grep zlib1g-dev | awk '{print \$2 " " \$3}')"
EOF

echo ""
echo "🎉 Reconfiguração concluída!"
echo ""
echo "✅ Bibliotecas instaladas:"
echo "  • build-essential - ferramentas de compilação"
echo "  • zlib1g-dev - biblioteca de compressão (resolve erro -lz)"
echo "  • libz-dev - alias para zlib"
echo "  • libstdc++-11-dev - biblioteca C++ padrão"
echo "  • libc6-dev - biblioteca C"
echo "  • libgtk2.0-dev - para interface gráfica"
echo "  • libxtst-dev - biblioteca X11 Testing"
echo ""
echo "📋 Próximos passos:"
echo "1. Verifique se o runner aparece online em:"
echo "   https://github.com/adrianbp/spring-native-servlet-poc/settings/actions/runners"
echo ""
echo "2. Teste com um workflow ARM:"
echo "   git commit --allow-empty -m 'Test ARM runner'"
echo "   git push origin main"

# Verificar status final
echo ""
echo "🔍 Status final do runner no GitHub:"
gh api repos/adrianbp/spring-native-servlet-poc/actions/runners --jq '.runners[] | select(.name=="graviton-runner") | {name: .name, status: .status, busy: .busy}' 2>/dev/null || echo "Use 'gh auth login' para verificar via API"
