#!/usr/bin/env bash
set -euo pipefail

AZ="${AZ:-az}"

if [[ -f azure/vm-info.env ]]; then
  # shellcheck disable=SC1091
  source azure/vm-info.env
fi

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-clyvo-cc}"

echo "Removendo Resource Group: $RESOURCE_GROUP"
$AZ resource list --resource-group "$RESOURCE_GROUP" -o table 2>/dev/null || true
$AZ group delete -n "$RESOURCE_GROUP" --yes --no-wait 2>/dev/null || true

echo ""
echo "Exclusao iniciada. Verifique no portal ou: az group list -o table"
