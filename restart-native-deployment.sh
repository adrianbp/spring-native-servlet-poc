#!/bin/bash

echo "==== Aplicando configurações e reiniciando deployment nativo ===="
kubectl apply -f k8s/native/

echo ""
echo "==== Reiniciando deployment ===="
kubectl rollout restart deployment/spring-native-app -n spring-native

echo ""
echo "==== Monitorando rollout (até 120s) ===="
kubectl rollout status deployment/spring-native-app -n spring-native --timeout=120s

echo ""
echo "==== Verificando pods após rollout ===="
kubectl get pods -n spring-native -o wide

echo ""
echo "==== Verificando eventos recentes ===="
kubectl get events -n spring-native --sort-by='.lastTimestamp' | tail -10

# Verifica se existem pods em execução
POD=$(kubectl get pods -n spring-native -l app=spring-native-app -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
if [ -n "$POD" ]; then
  echo ""
  echo "==== Verificando logs do pod $POD ===="
  kubectl logs $POD -n spring-native --tail=20
else
  echo ""
  echo "Nenhum pod em execução encontrado."
fi
