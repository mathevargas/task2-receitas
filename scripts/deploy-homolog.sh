#!/bin/bash

set -e

echo "Iniciando deploy do ambiente de Homologacao..."

docker compose up -d db-homolog
docker compose rm -sf app-homolog || true
docker compose up -d --build app-homolog

echo "Status dos containers de Homologacao:"
docker compose ps db-homolog app-homolog

echo "Deploy de Homologacao concluido."
