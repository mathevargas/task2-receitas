pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout / Git Pull') {
            steps {
                checkout scm
            }
        }

        stage('Preparar permissões') {
            steps {
                sh '''
                    chmod +x mvnw
                    chmod +x scripts/*.sh
                '''
            }
        }

        stage('Testes automatizados') {
            steps {
                sh './mvnw test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Linter - Checkstyle') {
            steps {
                sh './mvnw checkstyle:check'
            }
        }

        stage('Mess Detector - PMD') {
            steps {
                sh './mvnw pmd:check'
            }
        }

        stage('Build Maven') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Deploy Homologação') {
            steps {
                withCredentials([
                    string(credentialsId: 'EMAIL_APP', variable: 'EMAIL'),
                    string(credentialsId: 'SENHA_EMAIL_APP', variable: 'SENHA_EMAIL')
                ]) {
                    sh './scripts/deploy-homolog.sh'
                }
            }
        }

        stage('Aprovação Produção') {
            steps {
                input message: 'Homologação aprovada? Deseja atualizar Produção?', ok: 'Aprovar Produção'
            }
        }

        stage('Deploy Produção') {
            steps {
                withCredentials([
                    string(credentialsId: 'EMAIL_APP', variable: 'EMAIL'),
                    string(credentialsId: 'SENHA_EMAIL_APP', variable: 'SENHA_EMAIL')
                ]) {
                    sh './scripts/deploy-prod.sh'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline finalizado com sucesso.'
        }

        failure {
            echo 'Pipeline falhou. Verifique o stage com erro no Jenkins.'
        }

        always {
            echo 'Execução finalizada.'
        }
    }
}