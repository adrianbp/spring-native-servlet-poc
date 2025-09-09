#!/bin/bash

echo "==== Verificando status dos pods na namespace spring-native ===="
kubectl get pods -n spring-native

echo ""
echo "==== Verificando detalhes dos pods com problemas ===="
for pod in $(kubectl get pods -n spring-native -o jsonpath='{.items[?(@.status.phase!="Running")].metadata.name}'); do
  echo "Detalhes do pod $pod:"
  kubectl describe pod $pod -n spring-native
  echo ""
  echo "Logs do pod $pod (últimos 50 linhas):"
  kubectl logs $pod -n spring-native --tail=50
  echo ""
done

echo "==== Verificando nós onde os pods estão executando ===="
for pod in $(kubectl get pods -n spring-native -o jsonpath='{.items[*].metadata.name}'); do
  NODE=$(kubectl get pod $pod -n spring-native -o jsonpath='{.spec.nodeName}')
  ARCH=$(kubectl get node $NODE -o jsonpath='{.status.nodeInfo.architecture}')
  echo "Pod: $pod está executando no nó: $NODE (Arquitetura: $ARCH)"
done

echo ""
echo "==== Verificando eventos da namespace ===="
kubectl get events -n spring-native --sort-by='.lastTimestamp'

echo ""
echo "==== Verificando imagens em uso ===="
kubectl get pods -n spring-native -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].image}{"\n"}{end}'
