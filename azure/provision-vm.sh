#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-clyvo-cc}"
LOCATION="${LOCATION:-eastus}"
VM_NAME="${VM_NAME:-vm-clyvo-app}"
IMAGE="${IMAGE:-Ubuntu2404}"
SIZE="${SIZE:-Standard_B2s}"
ADMIN_USERNAME="${ADMIN_USERNAME:-admlnx}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Fiap@2tdsvms}"
TAG_OWNER="${TAG_OWNER:-Clyvo}"
TAG_PURPOSE="${TAG_PURPOSE:-Challenge}"
OUTPUT_FILE="${OUTPUT_FILE:-azure/vm-info.env}"

echo "Verificando Azure CLI..."
az account show >/dev/null

echo ""
echo "Criando Resource Group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
az group show -n "$RESOURCE_GROUP" \
  --query "{Name:name, Location:location, Tags:tags}" \
  --output table

echo ""
echo "Criando VM Linux..."
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "$IMAGE" \
  --size "$SIZE" \
  --authentication-type password \
  --admin-username "$ADMIN_USERNAME" \
  --admin-password "$ADMIN_PASSWORD" \
  --public-ip-sku Standard \
  --tags "owner=$TAG_OWNER" "purpose=$TAG_PURPOSE"

echo ""
echo "Liberando portas de rede (22, 8080, 1521)..."
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 22   --priority 1000
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 8080 --priority 1001
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 1521 --priority 1002

echo ""
echo "Instalando Docker e utilitarios..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "
    apt-get update -y && \
    apt-get install -y git nano curl && \
    curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    systemctl start docker && \
    systemctl enable docker && \
    usermod -aG docker ${ADMIN_USERNAME}
  "

echo ""
echo "Obtendo IP publico..."
VM_PUBLIC_IP=$(az network public-ip show \
  --resource-group "$RESOURCE_GROUP" \
  --name "${VM_NAME}PublicIP" \
  --query ipAddress \
  --output tsv)

mkdir -p "$(dirname "$OUTPUT_FILE")"
cat > "$OUTPUT_FILE" <<EOF
RESOURCE_GROUP=$RESOURCE_GROUP
LOCATION=$LOCATION
VM_NAME=$VM_NAME
ADMIN_USERNAME=$ADMIN_USERNAME
VM_PUBLIC_IP=$VM_PUBLIC_IP
API_URL=http://${VM_PUBLIC_IP}:8080
SWAGGER_URL=http://${VM_PUBLIC_IP}:8080/swagger
EOF

echo ""
echo "Provisionamento concluido."
echo "IP publico: $VM_PUBLIC_IP"
echo "Swagger (apos deploy): http://${VM_PUBLIC_IP}:8080/swagger"
echo "SSH: ssh ${ADMIN_USERNAME}@${VM_PUBLIC_IP}"
echo "Configuracao salva em: $OUTPUT_FILE"
echo ""
echo "Proximo comando:"
echo "  REPO_URL=https://github.com/USUARIO/REPO.git bash azure/deploy-app.sh"
