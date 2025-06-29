# Define as versões mínimas necessárias para o Terraform e provedores
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Versão do provedor AWS
    }
  }
}
