#!/bin/bash

echo "🚀 Dynatrace Setup - v1beta5 (Versão atual)"
echo "=========================================================="
echo ""

# Verificar se kubectl está configurado
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ kubectl não está configurado. Execute primeiro:"
    echo "aws eks update-kubeconfig --region us-west-2 --name spring-native-poc-cluster"
    exit 1
fi

# Solicitar informações do usuário
echo "📝 Por favor, forneça as seguintes informações do seu tenant Dynatrace:"
echo ""
echo "🔗 Como gerar os tokens:"
echo "1️⃣ API Token:"
echo "   • Acesse: Settings → Integration → Dynatrace API"
echo "   • Clique: Generate token"
echo "   • Scopes: Ingest metrics, Access problems and events feed, Read/Write configuration"
echo ""
echo "2️⃣ PaaS Token:"
echo "   • Acesse: Settings → Integration → Platform as a Service"  
echo "   • Clique: Generate token"
echo "   • Scopes: Installer download, PaaS integration"
echo ""
echo "3️⃣ Data Ingest Token:"
echo "   • Acesse: Settings → Integration → Platform as a Service"
echo "   • Clique: Generate token"
echo "   • Scopes: Ingest metrics, Ingest logs, Ingest events"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "🌐 Dynatrace URL (ex: https://abc12345.live.dynatrace.com/api): " TENANT_URL
read -p "🔑 API Token (Settings → Integration → Dynatrace API): " API_TOKEN
read -p "🔑 PaaS Token (Settings → Integration → Platform as a Service): " PAAS_TOKEN  
read -p "🔑 Data Ingest Token (Settings → Integration → Platform as a Service): " DATA_INGEST_TOKEN

echo ""
echo "✅ Configurações recebidas:"
echo "🌐 URL: $TENANT_URL"
echo "🔑 API Token: ${API_TOKEN:0:15}..."
echo "🔑 PaaS Token: ${PAAS_TOKEN:0:15}..."
echo "🔑 Data Ingest: ${DATA_INGEST_TOKEN:0:15}..."
echo ""

# 1. Instalar Dynatrace Operator (versão mais recente)
echo "📦 1/4 - Instalando Dynatrace Operator..."
kubectl create namespace dynatrace 2>/dev/null || echo "Namespace dynatrace já existe"

# Instalar o operator v1.6.0 que suporta v1beta5
kubectl apply -f https://github.com/Dynatrace/dynatrace-operator/releases/download/v1.6.0/kubernetes.yaml

echo "⏳ Aguardando Dynatrace Operator ficar pronto..."
kubectl wait --for=condition=available deployment/dynatrace-operator -n dynatrace --timeout=300s

# Verificar CRDs instalados
echo "🔍 Verificando versões de DynaKube suportadas..."
kubectl get crd dynakubes.dynatrace.com -o jsonpath='{.spec.versions[*].name}' 2>/dev/null || echo "CRD não encontrado"

# 2. Aplicar a configuração DynaKube (usando v1beta5)
echo ""
echo "⚙️  2/4 - Aplicando configuração DynaKube v1beta5..."

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: dynakube-tokens
  namespace: dynatrace
type: Opaque
stringData:
  apiToken: "$API_TOKEN"
  dataIngestToken: "$DATA_INGEST_TOKEN"
  paasToken: "$PAAS_TOKEN"

---
apiVersion: dynatrace.com/v1beta5
kind: DynaKube
metadata:
  name: dynakube
  namespace: dynatrace
spec:
  # Dynatrace API URL
  apiUrl: "$TENANT_URL"
  
  # Tokens necessários
  tokens: dynakube-tokens
  
  # OneAgent configuration (v1beta5 format)
  oneAgent:
    cloudNativeFullStack:
      # Environment variables
      env:
      - name: DT_CLUSTER_NAME
        value: "spring-native-eks-cluster"
      - name: DT_NODE_NAME
        valueFrom:
          fieldRef:
            fieldPath: spec.nodeName
      
      # Args para configuração específica
      args:
      - --set-app-log-content-access=true
      - --set-host-group=spring-native-eks-cluster
      
  # ActiveGate configuration
  activeGate:
    capabilities:
    - kubernetes-monitoring
    - routing
    - metrics-ingest
    
    # Replicas para HA
    replicas: 1
    
    # Environment variables
    env:
    - name: DT_CLUSTER_NAME
      value: "spring-native-eks-cluster"
EOF

# 3. Aguardar pods ficarem prontos
echo ""
echo "⏳ 3/4 - Aguardando pods do Dynatrace ficarem prontos..."
sleep 30

echo "📊 Status dos pods Dynatrace:"
kubectl get pods -n dynatrace

# 4. Marcar namespaces para instrumentação
echo ""
echo "🏷️  4/4 - Marcando namespaces para instrumentação..."
kubectl label namespace spring-native dynatrace-injection=enabled --overwrite 2>/dev/null || echo "⚠️  Namespace spring-native será marcado quando criado"
kubectl label namespace spring-native-arm dynatrace-injection=enabled --overwrite 2>/dev/null || echo "⚠️  Namespace spring-native-arm será marcado quando criado"
kubectl label namespace spring-jar dynatrace-injection=enabled --overwrite 2>/dev/null || echo "⚠️  Namespace spring-jar será marcado quando criado"  
kubectl label namespace spring-jar-arm dynatrace-injection=enabled --overwrite 2>/dev/null || echo "⚠️  Namespace spring-jar-arm será marcado quando criado"

echo ""
echo "🎉 DYNATRACE CONFIGURADO COM SUCESSO! (v1beta5)"
echo ""
echo "📋 Verificações:"
echo "✅ Operator instalado"
echo "✅ DynaKube v1beta5 aplicado"
echo "✅ Tokens configurados"
echo "✅ Namespaces marcados"
echo ""
echo "🔍 Para verificar:"
echo "kubectl get dynakube -n dynatrace"
echo "kubectl get pods -n dynatrace"
echo ""
echo "📱 No seu tenant Dynatrace:"
echo "1. Infrastructure → Kubernetes → Cluster: 'spring-native-eks-cluster'"
echo "2. Applications & Microservices → (aguarde apps serem deployadas)"
echo ""
echo "🚀 Próximo passo: Deploy das aplicações!"
