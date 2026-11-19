#!/bin/bash
# ==============================================================================
# infra.sh - Provisionamento da infraestrutura do Meu Bairro (CitizenTech)
# Cria via Azure CLI: Resource Group, App Service Plan (Linux) e Web App (.NET 10)
#
# Uso (Azure Cloud Shell - Bash, na raiz do repositório):
#   bash scripts/infra.sh <RM>
# Sem o parâmetro, o script pergunta o RM (deixa o nome do Web App único no Azure).
# ==============================================================================
set -e

RM="${1:-}"
if [ -z "$RM" ]; then
  read -r -p "Informe seu RM (usado no nome do Web App): " RM
fi
RM=$(echo "$RM" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
[ -n "$RM" ] || { echo "RM é obrigatório."; exit 1; }

RG=rg-meubairro
LOCATION=canadacentral
PLAN=plan-meubairro
APP=meubairro-api-$RM
RUNTIME="DOTNETCORE:10.0"

# Garante que há uma conta logada (no Cloud Shell já está)
az account show > /dev/null 2>&1 || az login

# Aviso (não bloqueia): confere se o runtime existe para Linux
if ! az webapp list-runtimes --os-type linux 2>/dev/null | grep -qi 'dotnetcore.10\.0'; then
  echo "AVISO: $RUNTIME não apareceu em 'az webapp list-runtimes --os-type linux'."
  echo "       Se o webapp create falhar, use o nome exibido por: az webapp list-runtimes --os-type linux | grep -i dotnet"
fi

echo ">> Registrando provider Microsoft.Web"
az provider register --namespace Microsoft.Web

echo ">> Criando Resource Group: $RG"
az group create --name $RG --location $LOCATION

echo ">> Criando App Service Plan (Linux, B1): $PLAN"
az appservice plan create --name $PLAN --resource-group $RG --sku B1 --is-linux

echo ">> Criando Web App ($RUNTIME): $APP"
az webapp create --name $APP --resource-group $RG --plan $PLAN --runtime "$RUNTIME"

echo ">> Configurando Web App"
az webapp config set --name $APP --resource-group $RG --always-on true --startup-file "sh startup.sh"
az webapp config appsettings set --name $APP --resource-group $RG \
  --settings WEBSITES_PORT=8080 ASPNETCORE_URLS=http://+:8080 --output none

echo ""
echo "Infraestrutura criada com sucesso."
echo "  Resource Group : $RG"
echo "  Web App        : $APP"
echo "  URL            : https://$APP.azurewebsites.net"
