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
    timeout  = "5m"
  }

  provisioner "file" {
    source      = "scripts/bootstrap-vm.sh"
    destination = "/tmp/bootstrap-vm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap-vm.sh",
      "sudo /tmp/bootstrap-vm.sh"
    ]
  }
}