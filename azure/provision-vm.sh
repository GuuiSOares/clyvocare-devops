#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-clyvo-cc}"
LOCATION="${LOCATION:-canadacentral}"
VM_NAME="${VM_NAME:-vm-clyvo-app}"
IMAGE="${IMAGE:-almalinux:almalinux-x86_64:10-gen2:10.1.202605180}"
SIZE="${SIZE:-Standard_B2ls_v2}"
ADMIN_USERNAME="${ADMIN_USERNAME:-admlnx}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Fiap@2tdsvms}"
OUTPUT_FILE="${OUTPUT_FILE:-azure/vm-info.env}"

AZ="${AZ:-az}"

echo "Verificando Azure CLI..."
$AZ account show >/dev/null

echo ""
echo "Resource Group: $RESOURCE_GROUP | Regiao: $LOCATION"
$AZ group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
$AZ group show -n "$RESOURCE_GROUP" \
  --query "{Name:name, Location:location}" \
  --output table

if $AZ vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" &>/dev/null; then
  echo "VM $VM_NAME ja existe."
  VM_SIZE_IN_USE=$($AZ vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "hardwareProfile.vmSize" -o tsv)
else
  echo "Criando VM ($SIZE)..."
  $AZ vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image "$IMAGE" \
    --size "$SIZE" \
    --authentication-type password \
    --admin-username "$ADMIN_USERNAME" \
    --admin-password "$ADMIN_PASSWORD" \
    --public-ip-sku Standard \
    --only-show-errors \
    --output none
  VM_SIZE_IN_USE="$SIZE"
fi

echo ""
echo "Liberando portas (22, 8080, 1521)..."
$AZ vm open-port -g "$RESOURCE_GROUP" -n "$VM_NAME" --port 22   --priority 1000 2>/dev/null || true
$AZ vm open-port -g "$RESOURCE_GROUP" -n "$VM_NAME" --port 8080 --priority 1001 2>/dev/null || true
$AZ vm open-port -g "$RESOURCE_GROUP" -n "$VM_NAME" --port 1521 --priority 1002 2>/dev/null || true

echo ""
echo "Instalando Docker (aguarde)..."
$AZ vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "
    dnf -y install dnf-plugins-core git curl && \
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
    systemctl enable --now docker && \
    usermod -aG docker ${ADMIN_USERNAME}
  " \
  --output none

VM_PUBLIC_IP=$($AZ network public-ip show \
  --resource-group "$RESOURCE_GROUP" \
  --name "${VM_NAME}PublicIP" \
  --query ipAddress \
  --output tsv)

mkdir -p "$(dirname "$OUTPUT_FILE")"
cat > "$OUTPUT_FILE" <<EOF
RESOURCE_GROUP=$RESOURCE_GROUP
LOCATION=$LOCATION
VM_NAME=$VM_NAME
VM_SIZE=$VM_SIZE_IN_USE
ADMIN_USERNAME=$ADMIN_USERNAME
VM_PUBLIC_IP=$VM_PUBLIC_IP
EOF

echo ""
echo "Concluido."
echo "Regiao: $LOCATION | VM: $VM_SIZE_IN_USE | IP: $VM_PUBLIC_IP"
echo "Arquivo: $OUTPUT_FILE"
echo "Proximo: REPO_URL=https://github.com/GuuiSOares/clyvocare-devops.git bash azure/deploy-app.sh"
