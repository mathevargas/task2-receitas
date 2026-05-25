#!/bin/bash

set -e

echo "Iniciando deploy do ambiente de Producao..."

docker compose up -d db-prod
docker compose rm -sf app-prod || true
docker compose up -d --build app-prod

echo "Status dos containers de Producao:"
docker compose ps db-prod app-prod

echo "Deploy de Producao concluido."
