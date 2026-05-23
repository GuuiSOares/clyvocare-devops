#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-}"
OUTPUT_FILE="${OUTPUT_FILE:-azure/vm-info.env}"

[[ -f "$OUTPUT_FILE" ]] || { echo "Execute azure/provision-vm.sh antes."; exit 1; }
# shellcheck disable=SC1090
source "$OUTPUT_FILE"

[[ -n "$REPO_URL" ]] || {
  echo "Uso: REPO_URL=https://github.com/USUARIO/REPO.git bash azure/deploy-app.sh"
  exit 1
}

echo "Publicando aplicacao na VM..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "
    set -e
    if [ ! -d clyvocare-devops ]; then
      git clone ${REPO_URL} clyvocare-devops
    fi
    cd clyvocare-devops
    git pull || true
    docker compose down || true
    docker compose up -d --build
    docker compose ps
  "

echo ""
echo "Deploy em andamento. Aguarde alguns minutos na primeira execucao (Oracle)."
echo "API:     http://${VM_PUBLIC_IP}:8080"
echo "Swagger: http://${VM_PUBLIC_IP}:8080/swagger"
echo "Health:  http://${VM_PUBLIC_IP}:8080/health"
