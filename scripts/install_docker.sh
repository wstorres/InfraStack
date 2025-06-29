#!/bin/bash
# Script para instalar Docker, Docker Compose e iniciar as aplicações
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Instala Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Instala Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Adiciona o usuário ubuntu ao grupo docker para não precisar de sudo
sudo usermod -aG docker ubuntu

# Navega para o diretório e executa o docker-compose
# NOTA: O docker-compose.yml deve ser transferido para a instância
# ou o user_data pode ser expandido para incluir o conteúdo do docker-compose.yml
# Para um projeto open-source, transferir é mais flexível.
# Por simplicidade, vou assumir que o docker-compose.yml será colocado em /home/ubuntu/
# ou em um volume persistente que será montado.

# Para este exemplo simples, vamos copiar o docker-compose.yml para a VM via user_data
# Esta é uma forma rudimentar, mas funcional para POC.
# Em um ambiente de produção, considere usar um serviço como S3 para o docker-compose.yml
# e baixá-lo na instância, ou um sistema de gestão de configuração.

echo '# Conteúdo do docker-compose.yml' | sudo tee /home/ubuntu/docker-compose.yml > /dev/null
# Adicionar o conteúdo do docker-compose.yml abaixo

# Inicia as aplicações Docker
cd /home/ubuntu/
sudo docker-compose up -d
