# Saídas importantes após a implantação
output "public_ip" {
  description = "Endereço IP público da instância EC2."
  value       = aws_instance.infrastack_server.public_ip
}

output "ssh_command" {
  description = "Comando SSH para acessar a instância."
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.infrastack_server.public_ip}"
}

output "glpi_url" {
  description = "URL provável do GLPI."
  value       = "http://${aws_instance.infrastack_server.public_ip}/glpi"
}

output "zabbix_url" {
  description = "URL provável do Zabbix."
  value       = "http://${aws_instance.infrastack_server.public_ip}:8080"
}

output "grafana_url" {
  description = "URL provável do Grafana."
  value       = "http://${aws_instance.infrastack_server.public_ip}:3000"
}

output "portainer_url" {
  description = "URL provável do Portainer."
  value       = "http://${aws_instance.infrastack_server.public_ip}:9000"
}
