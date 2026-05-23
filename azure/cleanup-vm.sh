#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-clyvo-cc}"

echo "Recursos no grupo $RESOURCE_GROUP:"
az resource list --resource-group "$RESOURCE_GROUP" -o table || true

echo ""
echo "Removendo Resource Group..."
az group delete -n "$RESOURCE_GROUP" --yes --no-wait

echo ""
echo "Exclusao iniciada."
echo "Acompanhe com: az group exists --name $RESOURCE_GROUP"
