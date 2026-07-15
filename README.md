# Sistema de Gestão de Receitas

Projeto final de uma aplicação web para gerenciamento de receitas, com pipeline de Integração Contínua e Entrega Contínua (CI/CD). A solução utiliza Spring Boot, PostgreSQL, Flyway, Docker, Jenkins, Terraform e ferramentas de qualidade para validar, empacotar e publicar a aplicação em homologação e produção.

## Funcionalidades

- Login de usuário
- Cadastro, edição, listagem e exclusão de receitas
- Filtros por tipo, nome e período de registro
- Geração de relatório em PDF
- Envio de e-mail ao cadastrar ou editar receitas
- Controle de banco com migrations Flyway
- Pipeline CI/CD com testes, análise de qualidade e aprovações manuais

## Tecnologias Utilizadas

- Java 21
- Spring Boot
- Spring Web MVC
- Thymeleaf
- Spring Data JPA / Hibernate
- PostgreSQL 17
- Flyway
- Maven
- JUnit / Spring Boot Test
- Checkstyle
- PMD
- Docker
- Docker Compose
- Jenkins
- Terraform

## Ambientes

| Ambiente | Serviço | Porta | Banco |
| --- | --- | --- | --- |
| Integração | Jenkins | 8090 | receitas_test |
| Homologação | app-homolog | 8080 | receitas_homolog |
| Produção | app-prod | 8081 | receitas_prod |

## Credenciais de Demonstração

Usuário inicial da aplicação:

- Login: admin
- Senha: admin@123

## Como Executar Localmente

### Pré-requisitos

- Java 21
- Docker e Docker Compose
- Git

### Subir o banco de testes

`docker compose --profile integration up -d db-test`

Banco local:

- Host: localhost
- Porta: 5433
- Database: receitas_test
- Usuário: postgres
- Senha: Postgres

### Aplicar migrations

Linux/macOS:

`./mvnw flyway:migrate -Dflyway.url=jdbc:postgresql://localhost:5433/receitas_test -Dflyway.user=postgres -Dflyway.password=Postgres`

Windows PowerShell:

`.\mvnw.cmd flyway:migrate -Dflyway.url=jdbc:postgresql://localhost:5433/receitas_test -Dflyway.user=postgres -Dflyway.password=Postgres`

### Rodar a aplicação

No Windows PowerShell:

`$env:SPRING_DATASOURCE_URL="jdbc:postgresql://localhost:5433/receitas_test"`

`$env:SPRING_DATASOURCE_USERNAME="postgres"`

`$env:SPRING_DATASOURCE_PASSWORD="Postgres"`

`.\mvnw.cmd spring-boot:run`

Acesse:

http://localhost:8080

## Qualidade e Testes

Checkstyle:

`./mvnw checkstyle:check`

PMD:

`./mvnw pmd:check`

Testes:

`./mvnw test`

Build:

`./mvnw clean package -DskipTests`

## Docker Compose

### Jenkins e integração

`docker compose --profile integration up -d --build`

Acesso:

http://localhost:8090

### Homologação

`docker compose --profile homolog up -d --build`

Acesso:

http://localhost:8080

### Produção

`docker compose --profile prod up -d --build`

Acesso:

http://localhost:8081

## Pipeline CI/CD

A pipeline definida no `Jenkinsfile` executa:

1. Checkout do código
2. Preparação do ambiente
3. Checkstyle
4. PMD
5. Migrations Flyway no banco de testes
6. Testes automatizados
7. Build Maven
8. Aprovação manual para homologação
9. Deploy em homologação
10. Aprovação manual para produção
11. Deploy em produção

Se Checkstyle, PMD ou testes falharem, a pipeline é interrompida e nenhum deploy é realizado.

## Deploy

Scripts de deploy:

- `./scripts/deploy-homolog.sh`
- `./scripts/deploy-prod.sh`

Eles recriam o container da aplicação e preservam os dados nos volumes dos bancos.

## Terraform

A pasta `terraform/` contém a automação usada para preparar a VM remota. O provisionamento acessa a VM por SSH, instala dependências e executa o script `bootstrap-vm.sh`, responsável por preparar Docker, Docker Compose e subir o ambiente de integração.

Exemplo de variáveis:

- `ssh_private_key_path = C:/Users/SEU_USUARIO/.ssh/task2_receitas_terraform`
- `jenkins_admin_user = admin`
- `jenkins_admin_password = SENHA_DO_JENKINS`
- `email_app = EMAIL_DO_APP`
- `senha_email_app = SENHA_DE_APP_DO_EMAIL`

Credenciais reais, senhas, chaves SSH e senhas de app não devem ser versionadas.

## Acessos do Ambiente Configurado

- Jenkins: http://177.44.248.40:8090
- Homologação: http://177.44.248.40:8080
- Produção: http://177.44.248.40:8081

Credenciais de demonstração do Jenkins:

- Usuário: jenkins
- Senha: admin123
