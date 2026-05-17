#!/bin/bash

set -e

echo "Atualizando pacotes da VM..."
apt update -y
apt upgrade -y

echo "Instalando pacotes basicos..."
apt install -y ca-certificates curl gnupg git unzip software-properties-common apt-transport-https

echo "Instalando Java 21..."
apt install -y openjdk-21-jdk

echo "Instalando Maven..."
apt install -y maven

echo "Instalando Docker..."
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

echo "Instalando Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update -y
apt install -y jenkins

echo "Configurando Jenkins para porta 8090..."
mkdir -p /etc/systemd/system/jenkins.service.d

cat > /etc/systemd/system/jenkins.service.d/override.conf <<EOF
[Service]
Environment="JENKINS_PORT=8090"
EOF

systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

echo "Aguardando Jenkins iniciar..."
sleep 40

echo "Instalando Jenkins CLI..."
JENKINS_CLI="/tmp/jenkins-cli.jar"

for i in {1..20}; do
  if curl -sSf http://localhost:8090/jnlpJars/jenkins-cli.jar -o "$JENKINS_CLI"; then
    echo "Jenkins CLI baixado com sucesso."
    break
  fi

  echo "Jenkins ainda nao esta pronto. Tentativa $i/20..."
  sleep 10
done

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ] && [ -f "$JENKINS_CLI" ]; then
  JENKINS_INITIAL_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)

  echo "Instalando plugins principais do Jenkins..."

  java -jar "$JENKINS_CLI" \
    -s http://localhost:8090/ \
    -auth admin:"$JENKINS_INITIAL_PASSWORD" \
    install-plugin \
    git \
    workflow-aggregator \
    pipeline-stage-view \
    credentials \
    credentials-binding \
    junit \
    docker-workflow \
    -deploy || true

  echo "Reiniciando Jenkins apos instalacao dos plugins..."
  systemctl restart jenkins
  sleep 20
else
  echo "Nao foi possivel instalar plugins automaticamente. Jenkins CLI ou senha inicial nao encontrados."
fi

echo "Adicionando usuario jenkins ao grupo docker..."
usermod -aG docker jenkins || true

echo "Adicionando usuario atual ao grupo docker, se existir..."
if id "$SUDO_USER" >/dev/null 2>&1; then
  usermod -aG docker "$SUDO_USER"
fi

echo "Liberando portas no firewall, se UFW estiver ativo..."
if command -v ufw >/dev/null 2>&1; then
  ufw allow 8080 || true
  ufw allow 8081 || true
  ufw allow 8090 || true
fi

echo "Versoes instaladas:"
git --version
java -version
mvn -version
docker --version
docker compose version

echo "Status Jenkins:"
systemctl status jenkins --no-pager || true

echo "Senha inicial do Jenkins:"
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
  cat /var/lib/jenkins/secrets/initialAdminPassword
else
  echo "Arquivo initialAdminPassword ainda nao encontrado."
fi

echo "Bootstrap da VM concluido."
echo "Acesse o Jenkins em: http://IP_DA_VM:8090"