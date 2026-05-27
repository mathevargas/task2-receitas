#!/bin/bash

set -e

echo "Iniciando deploy do ambiente de Producao..."

docker compose --profile prod up -d db-prod
docker compose --profile prod rm -sf app-prod || true
docker compose --profile prod up -d --build app-prod

echo "Status dos containers de Producao:"
docker compose --profile prod ps db-prod app-prod

echo "Deploy de Producao concluido."
