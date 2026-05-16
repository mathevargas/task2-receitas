output "jenkins_url" {
  value = "http://${var.vm_host}:8090"
}

output "homolog_url" {
  value = "http://${var.vm_host}:8080"
}

output "prod_url" {
  value = "http://${var.vm_host}:8081"
}