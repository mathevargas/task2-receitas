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

        stage('Subir Banco de Teste') {
            steps {
                sh './scripts/start-test-db.sh'
            }
        }

        stage('Testes automatizados') {
            environment {
                SPRING_DATASOURCE_URL = 'jdbc:postgresql://localhost:5433/receitas_test'
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
