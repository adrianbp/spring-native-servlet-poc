# Dashboard de Monitoramento do Endpoint /api/users

Este dashboard monitora especificamente o endpoint `/api/users` (GET) para comparar performance entre Native e JAR.

## Como usar:

### 1. Importar o Dashboard:
1. Acesse o Grafana: http://k8s-monitori-grafanap-60ad6f0ccb-2fac498ae8772309.elb.us-west-2.amazonaws.com:3000
2. Login: admin / admin123
3. Clique em "+" → "Import"
4. Cole o conteúdo de `dashboard-users-endpoint.json`
5. Clique em "Load" → "Import"

### 2. Executar Stress Test:
```bash
# Execute o teste de stress no endpoint específico
./stress-test.sh
```

## Métricas Monitoradas:

### 🚦 TPS (Transactions Per Second)
- **Native TPS**: `rate(http_server_requests_seconds_count{method="GET", uri="/api/users", job="spring-native-app"}[5m])`
- **JAR TPS**: `rate(http_server_requests_seconds_count{method="GET", uri="/api/users", job="spring-jar-app"}[5m])`

### ⏱️ Response Time
- **Native Avg**: Tempo médio de resposta da aplicação Native
- **JAR Avg**: Tempo médio de resposta da aplicação JAR

### 📊 Estatísticas Resumidas
- Total de TPS por aplicação
- Tempo de resposta médio comparativo

### 🔢 Total de Requests
- Contador acumulativo de requests processados

## Interpretação dos Resultados:

### TPS (Throughput):
- **Valor Ideal**: Maior é melhor
- **Native**: Normalmente maior devido à otimização de tempo de compilação
- **JAR**: Pode ter menor throughput inicial devido ao warm-up da JVM

### Response Time:
- **Valor Ideal**: Menor é melhor
- **Threshold Verde**: < 50ms
- **Threshold Amarelo**: 50-200ms  
- **Threshold Vermelho**: > 200ms

## Comandos Úteis:

### Verificar status dos pods:
```bash
kubectl get pods -n spring-native
kubectl get pods -n spring-jar
```

### Verificar logs específicos:
```bash
kubectl logs -f deployment/spring-native-app -n spring-native
kubectl logs -f deployment/spring-jar-app -n spring-jar
```

### Testar endpoint manualmente:
```bash
# Para Native
curl -X GET "http://$(kubectl get svc spring-native-app-service -n spring-native -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):8080/api/users"

# Para JAR  
curl -X GET "http://$(kubectl get svc spring-jar-app-service -n spring-jar -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):8080/api/users"
```

## Notas Importantes:

1. **Tempo de Warm-up**: A aplicação JAR pode precisar de alguns minutos para atingir performance máxima
2. **Coleta de Métricas**: As métricas são coletadas a cada 15 segundos pelo Prometheus
3. **Janela de Tempo**: Os gráficos usam uma janela de 5 minutos para suavizar as curvas
4. **Refresh**: Dashboard configurado para refresh automático a cada 5 segundos

## Dashboard URL:
Após importar, o dashboard estará disponível no Grafana através do link externo configurado.
