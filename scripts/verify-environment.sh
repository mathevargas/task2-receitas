#!/bin/bash

set -e

echo "Verificando ferramentas instaladas..."

echo "Git:"
git --version

echo "Java:"
java -version

echo "Maven:"
mvn -version

echo "Docker:"
docker --version

echo "Docker Compose:"
docker compose version

echo "Containers existentes:"
docker ps -a

echo "Volumes existentes:"
docker volume ls

echo "Verificacao concluida."