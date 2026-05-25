#!/bin/bash

set -e

if [ -z "${JENKINS_ADMIN_USER:-}" ] && [ -n "${JENKINS_ADMIN_USER_B64:-}" ]; then
  JENKINS_ADMIN_USER=$(printf "%s" "$JENKINS_ADMIN_USER_B64" | base64 -d)
fi

if [ -z "${JENKINS_ADMIN_PASSWORD:-}" ] && [ -n "${JENKINS_ADMIN_PASSWORD_B64:-}" ]; then
  JENKINS_ADMIN_PASSWORD=$(printf "%s" "$JENKINS_ADMIN_PASSWORD_B64" | base64 -d)
fi

if [ -z "${JENKINS_ADMIN_USER:-}" ] || [ -z "${JENKINS_ADMIN_PASSWORD:-}" ]; then
  echo "JENKINS_ADMIN_USER e JENKINS_ADMIN_PASSWORD sao obrigatorios."
  exit 1
fi

groovy_escape() {
  printf "%s" "$1" | sed "s/\\\\/\\\\\\\\/g; s/'/\\\\'/g"
}

wait_for_jenkins() {
  echo "Aguardando Jenkins responder na porta 8090..."

  for i in {1..60}; do
    if curl -sSf http://localhost:8090/login >/dev/null 2>&1; then
      echo "Jenkins esta respondendo."
      return 0
    fi

    echo "Jenkins ainda nao esta pronto. Tentativa $i/60..."
    sleep 5
  done

  echo "Jenkins nao respondeu dentro do tempo esperado."
  systemctl status jenkins --no-pager || true
  exit 1
}

echo "Limpando configuracoes antigas do repositorio Jenkins, se existirem..."
rm -f /usr/share/keyrings/jenkins-keyring.asc
rm -f /etc/apt/sources.list.d/jenkins.list
rm -f /etc/apt/trusted.gpg.d/jenkins*.gpg

echo "Atualizando pacotes da VM..."
apt update -y
apt upgrade -y

echo "Instalando pacotes basicos..."
apt install -y ca-certificates curl gnupg git unzip fontconfig software-properties-common apt-transport-https

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
rm -f /usr/share/keyrings/jenkins-keyring.asc
rm -f /etc/apt/sources.list.d/jenkins.list

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update -y
apt install -y jenkins

echo "Configurando Jenkins para porta 8090 e desativando wizard inicial..."
systemctl stop jenkins || true

mkdir -p /etc/systemd/system/jenkins.service.d
cat > /etc/systemd/system/jenkins.service.d/override.conf <<EOF
[Service]
Environment="JENKINS_PORT=8090"
Environment="JAVA_OPTS=-Djenkins.install.runSetupWizard=false"
EOF

echo "Criando usuario administrador inicial do Jenkins..."
mkdir -p /var/lib/jenkins/init.groovy.d

JENKINS_ADMIN_USER_ESCAPED=$(groovy_escape "$JENKINS_ADMIN_USER")
JENKINS_ADMIN_PASSWORD_ESCAPED=$(groovy_escape "$JENKINS_ADMIN_PASSWORD")

cat > /var/lib/jenkins/init.groovy.d/01-create-admin-user.groovy <<EOF
import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
import hudson.security.HudsonPrivateSecurityRealm
import jenkins.model.Jenkins

def instance = Jenkins.get()
def realm = new HudsonPrivateSecurityRealm(false)

if (realm.getUser('${JENKINS_ADMIN_USER_ESCAPED}') == null) {
    realm.createAccount('${JENKINS_ADMIN_USER_ESCAPED}', '${JENKINS_ADMIN_PASSWORD_ESCAPED}')
}

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)

instance.setSecurityRealm(realm)
instance.setAuthorizationStrategy(strategy)
instance.save()
EOF

chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d

echo "Adicionando usuario jenkins ao grupo docker..."
usermod -aG docker jenkins || true

echo "Adicionando usuario atual ao grupo docker, se existir..."
if [ -n "${SUDO_USER:-}" ] && id "$SUDO_USER" >/dev/null 2>&1; then
  usermod -aG docker "$SUDO_USER"
fi

systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins
wait_for_jenkins

echo "Instalando Jenkins CLI..."
JENKINS_CLI="/tmp/jenkins-cli.jar"
curl -sSf http://localhost:8090/jnlpJars/jenkins-cli.jar -o "$JENKINS_CLI"

echo "Instalando plugins principais do Jenkins..."
java -jar "$JENKINS_CLI" \
  -s http://localhost:8090/ \
  -auth "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" \
  install-plugin \
  git \
  workflow-aggregator \
  pipeline-stage-view \
  credentials \
  credentials-binding \
  junit \
  docker-workflow \
  -deploy

echo "Reiniciando Jenkins apos instalacao dos plugins..."
rm -f /var/lib/jenkins/init.groovy.d/01-create-admin-user.groovy
systemctl restart jenkins
wait_for_jenkins

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
echo "Jenkins: http://$(hostname -I | awk '{print $1}'):8090"
echo "Homologacao: http://$(hostname -I | awk '{print $1}'):8080"
echo "Producao: http://$(hostname -I | awk '{print $1}'):8081"
