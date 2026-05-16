variable "vm_host" {
  description = "IP ou host da VM da Univates"
  type        = string
}

variable "vm_user" {
  description = "Usuario SSH da VM"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Caminho da chave privada SSH local"
  type        = string
}