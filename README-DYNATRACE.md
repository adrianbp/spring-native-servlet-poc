# Configuração do Dynatrace Operator

O Dynatrace Operator já foi instalado no cluster e está pronto para coletar métricas avançadas das suas aplicações Spring Native vs JAR.

## 🎯 Objetivos do Monitoramento

- **Comparação de Performance**: Native vs JAR em tempo real
- **Métricas Profundas**: CPU, Memória, Network, JVM (quando aplicável)
- **Distributed Tracing**: Rastreamento de requests end-to-end
- **Real User Monitoring**: Performance vista do usuário final
- **Infrastructure Monitoring**: Saúde dos nodes Kubernetes

## 📋 Pré-requisitos

1. **Conta Dynatrace** (pode ser trial gratuita)
2. **Acesso ao tenant** Dynatrace
3. **Tokens de acesso** (API Token + Data Ingest Token)

### Como obter uma conta Dynatrace (Gratuita):
1. Acesse: https://www.dynatrace.com/trial/
2. Registre-se para uma conta gratuita (15 dias)
3. Anote a URL do seu tenant (ex: `https://abc12345.live.dynatrace.com`)

## 🔑 Gerando os Tokens Necessários

### 1. API Token
1. Acesse seu tenant Dynatrace
2. Vá para: **Settings** → **Integration** → **Dynatrace API**
3. Clique em **"Generate token"**
4. Nome: `kubernetes-operator`
5. Selecione os scopes:
   - ✅ `Ingest metrics` (metrics.ingest)
   - ✅ `Access problems and events feed` (events.ingest)  
   - ✅ `Read configuration` (ReadConfig)
   - ✅ `Write configuration` (WriteConfig)
   - ✅ `Read entities` (entities.read)
6. Copie o token gerado

### 2. Data Ingest Token  
1. Vá para: **Settings** → **Integration** → **Platform as a Service**
2. Clique em **"Generate token"**
3. Nome: `kubernetes-metrics`
4. Copie o token gerado

## ⚡ Instalação Rápida

Execute o script de configuração com seus tokens:

```bash
./setup-dynatrace.sh <TENANT_URL> <API_TOKEN> <DATA_INGEST_TOKEN>
```

### Exemplo:
```bash
./setup-dynatrace.sh \
  https://abc12345.live.dynatrace.com/api \
  dt0s01.XXXXXXXXXXXXXXXXXXXXXXXXXX \
  dt0s02.YYYYYYYYYYYYYYYYYYYYYYYYYY
```

## 🔍 Verificação da Instalação

### 1. Verificar Pods:
```bash
kubectl get pods -n dynatrace
```

Deve mostrar:
- ✅ dynatrace-operator (1/1 Running)
- ✅ dynatrace-webhook (2/2 Running)  
- ✅ dynatrace-oneagent-csi-driver (4/4 Running em cada node)

### 2. Verificar DynaKubes:
```bash
kubectl get dynakube -n dynatrace
```

Deve mostrar:
- ✅ spring-monitoring (Running)
- ✅ kubernetes-monitoring (Running)

### 3. Verificar Labels dos Namespaces:
```bash
kubectl get namespace spring-native spring-jar --show-labels
```

Deve mostrar: `dynatrace-monitoring=enabled`

## 📊 Acessando o Dynatrace

1. **Login no Tenant**: Acesse sua URL do Dynatrace
2. **Infrastructure**: Vá para `Infrastructure` → `Kubernetes`
   - Deve aparecer o cluster `eks-spring-poc`
3. **Applications**: Vá para `Applications & Microservices`
   - Deve aparecer as apps `spring-native-app` e `spring-jar-app`

## 🚀 Executando Testes de Performance

### Teste de Carga:
```bash
./stress-test.sh
```

### Monitoramento em Tempo Real:
- **Dynatrace**: Dashboard nativo do Dynatrace
- **Grafana**: http://k8s-monitori-grafanap-60ad6f0ccb-2fac498ae8772309.elb.us-west-2.amazonaws.com:3000
- **Prometheus**: http://k8s-monitori-promethe-b6df9b4e76-15a3a66d89e1b1b7.elb.us-west-2.amazonaws.com:9090

## 📈 Dashboards Disponíveis

### 1. Dynatrace (Nativo):
- **Kubernetes Overview**: Visão geral do cluster
- **Application Performance**: Performance das aplicações
- **Real User Monitoring**: Performance do usuário final
- **Infrastructure**: Saúde dos nodes

### 2. Grafana (Personalizado):
- **Endpoint Específico**: `/api/users` monitoring
- **Comparação Native vs JAR**: Side-by-side
- **Métricas Prometheus**: Integração existente

## 🔧 Configurações Avançadas

### Habilitando Log Monitoring:
```bash
kubectl annotate namespace spring-native dynatrace.com/log-monitoring=enabled
kubectl annotate namespace spring-jar dynatrace.com/log-monitoring=enabled
```

### Configurando Custom Metrics:
As aplicações já expõem métricas Prometheus que serão automaticamente coletadas pelo Dynatrace.

### Distributed Tracing:
O OneAgent automaticamente instrumenta as aplicações Java para distributed tracing.

## 🐛 Troubleshooting

### Pods não estão sendo instrumentados:
```bash
# Verificar se o webhook está funcionando
kubectl logs deployment/dynatrace-webhook -n dynatrace

# Verificar anotações dos pods
kubectl describe pod -l app=spring-native-app -n spring-native
kubectl describe pod -l app=spring-jar-app -n spring-jar
```

### OneAgent não está coletando métricas:
```bash
# Verificar logs do CSI driver
kubectl logs daemonset/dynatrace-oneagent-csi-driver -n dynatrace -c driver

# Verificar status do DynaKube
kubectl describe dynakube spring-monitoring -n dynatrace
```

### Conectividade com Dynatrace:
```bash
# Testar conectividade
kubectl run debug-pod --rm -i --tty --image=curlimages/curl -- \
  curl -H "Authorization: Api-Token SEU_API_TOKEN" \
  https://SEU_TENANT.live.dynatrace.com/api/v1/config/clusterversion
```

## 📚 Recursos Adicionais

- **Documentação Oficial**: https://docs.dynatrace.com/docs/setup-and-configuration/setup-on-k8s/
- **GitHub Operator**: https://github.com/Dynatrace/dynatrace-operator
- **Community**: https://community.dynatrace.com/

## 🎯 Próximos Passos

1. ✅ **Instalar Dynatrace** (Concluído)
2. 🔄 **Configurar com seus tokens** (`./setup-dynatrace.sh`)
3. 📊 **Executar testes** (`./stress-test.sh`)
4. 📈 **Analisar resultados** no Dynatrace
5. 🎨 **Criar dashboards personalizados**

---

**💡 Dica**: O Dynatrace oferece muito mais insights que o Prometheus+Grafana, incluindo AI-powered root cause analysis, real user monitoring, e aplicação dependency mapping automático!
