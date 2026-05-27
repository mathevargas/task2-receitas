#!/bin/bash

set -e

PROJECT_DIR="/home/univates/task2-receitas"
REPOSITORY_URL="https://github.com/mathevargas/task2-receitas.git"

decode_b64_var() {
  local source_value="$1"
  printf "%s" "$source_value" | base64 -d
}

if [ -z "${JENKINS_ADMIN_USER:-}" ] && [ -n "${JENKINS_ADMIN_USER_B64:-}" ]; then
  JENKINS_ADMIN_USER=$(decode_b64_var "$JENKINS_ADMIN_USER_B64")
fi

if [ -z "${JENKINS_ADMIN_PASSWORD:-}" ] && [ -n "${JENKINS_ADMIN_PASSWORD_B64:-}" ]; then
  JENKINS_ADMIN_PASSWORD=$(decode_b64_var "$JENKINS_ADMIN_PASSWORD_B64")
fi

if [ -z "${EMAIL_APP:-}" ] && [ -n "${EMAIL_APP_B64:-}" ]; then
  EMAIL_APP=$(decode_b64_var "$EMAIL_APP_B64")
fi

if [ -z "${SENHA_EMAIL_APP:-}" ] && [ -n "${SENHA_EMAIL_APP_B64:-}" ]; then
  SENHA_EMAIL_APP=$(decode_b64_var "$SENHA_EMAIL_APP_B64")
fi

if [ -z "${JENKINS_ADMIN_USER:-}" ] \
  || [ -z "${JENKINS_ADMIN_PASSWORD:-}" ] \
  || [ -z "${EMAIL_APP:-}" ] \
  || [ -z "${SENHA_EMAIL_APP:-}" ]; then
  echo "JENKINS_ADMIN_USER, JENKINS_ADMIN_PASSWORD, EMAIL_APP e SENHA_EMAIL_APP sao obrigatorios."
  exit 1
fi

echo "Atualizando pacotes da VM..."
apt update -y

echo "Instalando dependencias basicas..."
apt install -y ca-certificates curl gnupg git

echo "Instalando Docker e Docker Compose plugin, se necessario..."
install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Habilitando Docker..."
systemctl enable docker
systemctl start docker

echo "Adicionando usuario univates ao grupo docker, se existir..."
if id univates >/dev/null 2>&1; then
  usermod -aG docker univates
fi

echo "Preparando repositorio do projeto sem apagar a pasta existente..."
if [ -d "$PROJECT_DIR/.git" ]; then
  git -C "$PROJECT_DIR" fetch origin main
  git -C "$PROJECT_DIR" checkout main
  git -C "$PROJECT_DIR" pull --ff-only origin main
elif [ -d "$PROJECT_DIR" ]; then
  echo "A pasta $PROJECT_DIR ja existe, mas nao e um repositorio Git. Nao vou apagar essa pasta."
  echo "Ajuste a pasta manualmente ou mova o conteudo antigo antes de rodar o bootstrap novamente."
  exit 1
else
  git clone "$REPOSITORY_URL" "$PROJECT_DIR"
fi

if id univates >/dev/null 2>&1; then
  chown -R univates:univates "$PROJECT_DIR"
fi

echo "Gerando .env local para Docker Compose na VM..."
cat > "$PROJECT_DIR/.env" <<EOF
JENKINS_ADMIN_USER=${JENKINS_ADMIN_USER}
JENKINS_ADMIN_PASSWORD=${JENKINS_ADMIN_PASSWORD}
EMAIL_APP=${EMAIL_APP}
SENHA_EMAIL_APP=${SENHA_EMAIL_APP}
EOF
chmod 600 "$PROJECT_DIR/.env"

if id univates >/dev/null 2>&1; then
  chown univates:univates "$PROJECT_DIR/.env"
fi

echo "Subindo somente ambiente de integracao: Jenkins e db-test..."
cd "$PROJECT_DIR"
docker compose --profile integration up -d --build jenkins db-test

echo "Status dos containers de integracao:"
docker compose --profile integration ps jenkins db-test

echo "Liberando portas no firewall, se UFW estiver ativo..."
if command -v ufw >/dev/null 2>&1; then
  ufw allow 8090 || true
  ufw allow 8080 || true
  ufw allow 8081 || true
fi

echo "Versoes instaladas:"
git --version
docker --version
docker compose version

echo "Bootstrap concluido."
echo "Jenkins: http://177.44.248.40:8090"
echo "Homologacao sera iniciada pelo botao da pipeline: http://177.44.248.40:8080"
echo "Producao sera iniciada pelo botao da pipeline: http://177.44.248.40:8081"
