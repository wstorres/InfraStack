# Variáveis para configuração da AWS
variable "aws_region" {
  description = "Região da AWS para implantar os recursos."
  type        = string
  default     = "us-east-1" # Exemplo: Virginia
}

variable "instance_type" {
  description = "Tipo de instância EC2 para hospedar o Docker e as aplicações."
  type        = string
  default     = "t2.medium" # Suficiente para começar, pode ser ajustado
}

variable "ami_id" {
  description = "ID da AMI (Amazon Machine Image) para a instância EC2 (Ubuntu Server)."
  type        = string
  # Sugestão: Use uma AMI Ubuntu LTS recente. Verifique a mais atual na sua região.
  # Ex: ami-053b0dcd10dcfd54e para Ubuntu Server 22.04 LTS em us-east-1 (AMD64)
  default = "ami-053b0dcd10dcfd54e"
}

variable "key_name" {
  description = "Nome da chave EC2 para acesso SSH à instância."
  type        = string
}

variable "vpc_cidr_block" {
  description = "Bloco CIDR para a VPC (Virtual Private Cloud)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "Bloco CIDR para a Subnet Pública."
  type        = string
  default     = "10.0.1.0/24"
}
