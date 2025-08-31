#!/bin/bash

# Deploy Monitoring Stack to Kubernetes
echo "🚀 Deploying Monitoring Stack to Kubernetes"
echo "==========================================="

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl is not configured or cluster is not accessible"
    echo "Run: aws eks update-kubeconfig --region us-west-2 --name spring-native-poc-cluster"
    exit 1
fi

echo "📊 Deploying Prometheus and Grafana..."

# Deploy monitoring namespace
kubectl apply -f k8s/monitoring/namespace.yaml

# Deploy Prometheus
kubectl apply -f k8s/monitoring/prometheus.yaml

# Deploy Grafana
kubectl apply -f k8s/monitoring/grafana.yaml

echo "✅ Monitoring stack deployed!"
echo

echo "🔗 Access Information:"
echo "======================"
echo "Prometheus:"
echo "  kubectl port-forward -n monitoring service/prometheus 9090:9090"
echo "  Then access: http://localhost:9090"
echo
echo "Grafana:"
echo "  kubectl port-forward -n monitoring service/grafana 3000:3000"
echo "  Then access: http://localhost:3000"
echo "  Credentials: admin / admin123"
echo

echo "📈 To check services status:"
echo "kubectl get pods -n monitoring"
echo "kubectl get services -n monitoring"

# Optional: Wait for pods to be ready
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=300s

echo "🎉 Monitoring stack is ready!"
