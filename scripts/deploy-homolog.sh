#!/bin/bash

set -e

echo "Iniciando deploy do ambiente de Homologacao..."

docker compose --profile homolog up -d db-homolog
docker compose --profile homolog rm -sf app-homolog || true
docker compose --profile homolog up -d --build app-homolog

echo "Status dos containers de Homologacao:"
docker compose --profile homolog ps db-homolog app-homolog

echo "Deploy de Homologacao concluido."
