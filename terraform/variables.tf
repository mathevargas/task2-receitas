variable "vm_host" {
  description = "IP ou host da VM da Univates"
  type        = string
  default     = "177.44.248.40"
}

variable "vm_user" {
  description = "Usuario SSH da VM"
  type        = string
  default     = "univates"
}

variable "vm_password" {
  description = "Senha SSH da VM"
  type        = string
  sensitive   = true
}

variable "ssh_private_key_path" {
  description = "Caminho local da chave privada SSH usada pelo Terraform"
  type        = string
  sensitive   = true
}

variable "jenkins_admin_user" {
  description = "Usuario administrador inicial do Jenkins"
  type        = string
}

variable "jenkins_admin_password" {
  description = "Senha do usuario administrador inicial do Jenkins"
  type        = string
  sensitive   = true
}

variable "email_app" {
  description = "E-mail usado pela aplicacao"
  type        = string
  sensitive   = true
}

variable "senha_email_app" {
  description = "Senha de app do e-mail usado pela aplicacao"
  type        = string
  sensitive   = true
}
