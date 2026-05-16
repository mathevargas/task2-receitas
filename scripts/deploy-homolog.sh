#!/bin/bash

set -e

echo "Iniciando deploy do ambiente de Homologacao..."

docker compose up -d --build db-homolog app-homolog

echo "Status dos containers de Homologacao:"
docker compose ps db-homolog app-homolog

echo "Deploy de Homologacao concluido."