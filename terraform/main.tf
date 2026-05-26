terraform {
  required_version = ">= 1.5.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

resource "null_resource" "prepare_vm" {
  connection {
    type     = "ssh"
    host     = var.vm_host
    user     = var.vm_user
    password = var.vm_password
    agent    = false
    timeout  = "15m"

    script_path = "/tmp/terraform_%RAND%.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y curl ca-certificates",
      "curl -fsSL -o /tmp/bootstrap-vm.sh https://raw.githubusercontent.com/mathevargas/task2-receitas/main/terraform/scripts/bootstrap-vm.sh",
      "chmod +x /tmp/bootstrap-vm.sh",
      "sudo JENKINS_ADMIN_USER_B64='${base64encode(var.jenkins_admin_user)}' JENKINS_ADMIN_PASSWORD_B64='${base64encode(var.jenkins_admin_password)}' /tmp/bootstrap-vm.sh"
    ]
  }
}
