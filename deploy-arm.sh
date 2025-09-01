#!/bin/bash

echo "🚀 Deploying ARM64 Applications to EKS..."

# Deploy Native ARM
echo "📦 Deploying Spring Native ARM64..."
kubectl apply -f k8s/native-arm/

# Deploy JAR ARM  
echo "📦 Deploying Spring JAR ARM64..."
kubectl apply -f k8s/jar-arm/

# Update Prometheus configuration to include ARM services
echo "📊 Updating Prometheus configuration for ARM monitoring..."
kubectl apply -f k8s/monitoring/prometheus-config-arm.yaml

# Restart Prometheus to load new configuration
echo "🔄 Restarting Prometheus..."
kubectl rollout restart deployment/prometheus -n monitoring

echo "⏰ Waiting for deployments to be ready..."
echo "🔍 Native ARM64 deployment status:"
kubectl rollout status deployment/spring-native-app-arm -n spring-native-arm --timeout=300s

echo "🔍 JAR ARM64 deployment status:"
kubectl rollout status deployment/spring-jar-app-arm -n spring-jar-arm --timeout=300s

echo "✅ ARM64 deployments completed!"

echo ""
echo "📊 Services status:"
kubectl get svc -n spring-native-arm
kubectl get svc -n spring-jar-arm

echo ""
echo "🎯 LoadBalancer URLs (will be available in a few minutes):"
echo "Native ARM64: $(kubectl get svc spring-native-app-arm-loadbalancer -n spring-native-arm -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):8080"
echo "JAR ARM64: $(kubectl get svc spring-jar-app-arm-loadbalancer -n spring-jar-arm -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):8080"
