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

echo "Bootstrap da VM concluido."