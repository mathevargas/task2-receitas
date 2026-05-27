pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Preparar ambiente') {
            steps {
                sh '''
                    chmod +x mvnw
                    chmod +x scripts/*.sh
                '''
            }
        }

        stage('Checkstyle') {
            steps {
                sh './mvnw checkstyle:check'
            }
        }

        stage('PMD') {
            steps {
                sh './mvnw pmd:check'
            }
        }

        stage('Testes automatizados') {
            environment {
                SPRING_DATASOURCE_URL = 'jdbc:postgresql://db-test:5432/receitas_test'
                SPRING_DATASOURCE_USERNAME = 'postgres'
                SPRING_DATASOURCE_PASSWORD = 'Postgres'
                SPRING_JPA_HIBERNATE_DDL_AUTO = 'none'
            }
            steps {
                sh './mvnw test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build Maven') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Aprovar Homologacao') {
            steps {
                input message: 'Integracao aprovada. Deseja subir ou atualizar Homologacao?', ok: 'Deploy Homologacao'
            }
        }

        stage('Deploy Homologacao') {
            steps {
                withCredentials([
                    string(credentialsId: 'EMAIL_APP', variable: 'EMAIL'),
                    string(credentialsId: 'SENHA_EMAIL_APP', variable: 'SENHA_EMAIL')
                ]) {
                    sh './scripts/deploy-homolog.sh'
                }
            }
        }

        stage('Aprovar Producao') {
            steps {
                input message: 'Homologacao validada. Deseja subir ou atualizar Producao?', ok: 'Deploy Producao'
            }
        }

        stage('Deploy Producao') {
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
            echo 'Execucao finalizada.'
        }
    }
}
