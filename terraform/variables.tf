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