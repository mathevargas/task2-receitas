#!/bin/bash

set -e

echo "Preparando banco PostgreSQL de teste..."

docker compose rm -sfv db-test || true

docker compose up -d db-test

echo "Aguardando db-test ficar saudavel..."
for i in {1..30}; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' db-test 2>/dev/null || echo "starting")

  if [ "$STATUS" = "healthy" ]; then
    echo "db-test esta saudavel."
    break
  fi

  if [ "$i" -eq 30 ]; then
    echo "db-test nao ficou saudavel dentro do tempo esperado."
    docker compose ps db-test
    docker logs db-test || true
    exit 1
  fi

  echo "Status atual do db-test: $STATUS. Tentativa $i/30..."
  sleep 2
done

echo "Status do banco de teste:"
docker compose ps db-test
