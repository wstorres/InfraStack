# Cria uma VPC para isolar a infraestrutura
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "infrastack-vpc"
  }
}

# Cria uma Internet Gateway para a VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "infrastack-igw"
  }
}

# Cria uma Subnet pública
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_block
  map_public_ip_on_launch = true # Para a instância ter IP público
  availability_zone = "${var.aws_region}a" # Use uma AZ na sua região
  tags = {
    Name = "infrastack-public-subnet"
  }
}

# Tabela de Roteamento para a subnet pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "infrastack-public-rt"
  }
}

# Associa a tabela de roteamento à subnet pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Grupo de Segurança para permitir SSH, HTTP e HTTPS
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id
  name   = "infrastack-instance-sg"
  description = "Permite SSH, HTTP, HTTPS e portas de serviço das aplicações"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite SSH de qualquer lugar (ajustar em produção!)
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTP
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTPS
  }
  # Portas específicas das aplicações
  ingress {
    from_port   = 3000 # Grafana
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000 # Portainer
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080 # Zabbix web
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8081 # GLPI (se configurado em porta diferente de 80)
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Permite todo tráfego de saída
  }

  tags = {
    Name = "infrastack-instance-sg"
  }
}

# Cria a instância EC2
resource "aws_instance" "infrastack_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  # Script de bootstrap para instalar Docker e Docker Compose e rodar docker-compose
  user_data = filebase64("${path.module}/scripts/install_docker.sh")

  tags = {
    Name = "InfrastackServer"
  }
}
