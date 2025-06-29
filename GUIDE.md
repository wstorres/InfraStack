# 📚 Manual de Implantação do InfraStack

---

Este manual foi criado para guiar você, passo a passo, na implantação do **InfraStack** em sua própria infraestrutura na **AWS (Amazon Web Services)**. Não se preocupe se você não tem experiência prévia com Terraform, Docker ou nuvem; vamos simplificar ao máximo!

---

## 🎯 O Que Você Vai Fazer

Você vai usar o **Terraform**, uma ferramenta que nos permite "escrever" a infraestrutura como código, para criar automaticamente um servidor na nuvem (AWS). Neste servidor, vamos instalar o Docker e, em seguida, as ferramentas GLPI, Zabbix, Grafana e Portainer, que são essenciais para gerenciar e monitorar seu ambiente de TI.

---

## 📝 Pré-requisitos (O Que Você Precisa Ter Antes de Começar)

Antes de iniciar, certifique-se de ter o seguinte:

1.  **Conta na AWS:** Você precisa de uma conta ativa na Amazon Web Services. Se não tiver, pode criar uma em [aws.amazon.com](https://aws.amazon.com/). Muitas das ferramentas que usaremos são elegíveis para o **Free Tier** (camada gratuita), mas fique atento aos custos para não ter surpresas.

2.  **Chave SSH na AWS:** Para acessar o servidor que será criado, você precisa de uma chave SSH (par de chaves pública e privada) registrada na sua conta AWS.
    * **Como criar (se você não tiver):**
        * Acesse o console da AWS.
        * Vá para **EC2 > Key Pairs (Pares de Chaves)** no menu lateral.
        * Clique em **"Create key pair"**.
        * Dê um nome fácil de lembrar (ex: `minha-chave-infrastack`).
        * Escolha o formato `.pem` e clique em **"Create key pair"**.
        * O arquivo `.pem` será baixado para o seu computador. **Guarde-o em um local seguro** (ex: na pasta `~/.ssh/` no Linux/macOS ou em um local seguro no Windows).

3.  **Git Instalado:** O Git é uma ferramenta para baixar e gerenciar o código do projeto.
    * **Windows:** Baixe e instale o Git Bash em [git-scm.com/download/win](https://git-scm.com/download/win).
    * **macOS:** Você pode instalar via Homebrew (`brew install git`) ou instalar as Xcode Command Line Tools (`xcode-select --install`).
    * **Linux (Ubuntu/Debian):** `sudo apt update && sudo apt install git -y`.

4.  **Terraform Instalado:** O Terraform é a ferramenta que fará a mágica de criar sua infraestrutura.
    * **Como instalar:** Siga as instruções oficiais no site da HashiCorp: [developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads). Escolha a versão para o seu sistema operacional.
    * Após a instalação, abra seu terminal (ou Git Bash no Windows) e digite `terraform version` para verificar se está funcionando.

5.  **Credenciais da AWS Configuradas:** O Terraform precisa saber como se conectar à sua conta AWS. A maneira mais fácil é usar o AWS CLI (Interface de Linha de Comando).
    * **Instale o AWS CLI:** Siga as instruções em [docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
    * Após a instalação, no seu terminal, digite `aws configure`. Ele pedirá:
        * `AWS Access Key ID`: Sua chave de acesso.
        * `AWS Secret Access Key`: Sua chave secreta.
        * `Default region name`: Digite `us-east-1` (ou a região AWS que você prefere usar).
        * `Default output format`: Deixe em branco ou digite `json`.
    * Você pode gerar suas chaves de acesso no console da AWS: vá em seu **Nome de Usuário (canto superior direito) > Security Credentials > Access keys**.

---

## ⚙️ Configuração dos Arquivos do Projeto

Agora que você tem os pré-requisitos, vamos configurar os arquivos do projeto InfraStack.

1.  **Clone o Repositório:** Abra seu terminal (ou Git Bash) e navegue até a pasta onde você quer baixar o projeto. Em seguida, clone o repositório do GitHub:

    ```bash
    git clone [https://github.com/SeuUsuario/infrastack.git](https://github.com/SeuUsuario/infrastack.git)
    cd infrastack
    ```

    *Substitua `SeuUsuario` pelo seu nome de usuário no GitHub.*

2.  **Edite o `install_docker.sh` (Passo Importante!):**
    Dentro da pasta `infrastack`, você verá uma pasta chamada `scripts`. Nela, há dois arquivos: `install_docker.sh` e `docker-compose.yml`.
    * Abra o arquivo `scripts/install_docker.sh` com um editor de texto (pode ser o Bloco de Notas no Windows, ou Sublime Text, VS Code, Atom, etc.).
    * Encontre a linha que contém `# Conteúdo do docker-compose.yml`.
    * **Copie TODO o conteúdo do arquivo `scripts/docker-compose.yml`** e cole-o imediatamente abaixo dessa linha, dentro do comando `echo` do `install_docker.sh`.
    * **Atenção:** As senhas dentro do `docker-compose.yml` (para GLPI e Zabbix) estão como exemplos. **MUDE-AS PARA SENHAS FORTES E SEGURAS IMEDIATAMENTE!** Por exemplo:

        ```yaml
        # ... (dentro do docker-compose.yml que você vai colar)
            environment:
              - MYSQL_ROOT_PASSWORD=SuaSenhaSuperSegura123! # Mude aqui
              - MYSQL_DATABASE=glpidb
              # ...
        ```

    * O final do seu `install_docker.sh` deve ficar parecido com isto (o trecho `# Conteúdo do docker-compose.yml` será substituído pelo conteúdo real):

        ```bash
        # ... (código existente do install_docker.sh) ...

        echo 'version: "3.8"

        services:
          glpi:
            image: glpi/glpi:latest
            container_name: glpi
            ports:
              - "80:80"
            environment:
              - MYSQL_ROOT_PASSWORD=SUA_SENHA_FORTE_AQUI_GLPI
              - MYSQL_DATABASE=glpidb
              - MYSQL_USER=glpiuser
              - MYSQL_PASSWORD=SUA_SENHA_DE_USUARIO_GLPI
            volumes:
              - glpi_data:/var/www/html
            depends_on:
              - glpi_db
            restart: unless-stopped
          # ... (resto do conteúdo do docker-compose.yml) ...
        ' | sudo tee /home/ubuntu/docker-compose.yml > /dev/null

        # Inicia as aplicações Docker
        cd /home/ubuntu/
        sudo docker-compose up -d
        ```

    * **Salve as alterações** no arquivo `scripts/install_docker.sh`.

3.  **Crie e Edite o `terraform.tfvars`:**
    * Na pasta principal do projeto (`infrastack`), você encontrará um arquivo chamado `terraform.tfvars.example`.
    * **Faça uma cópia** deste arquivo e renomeie a cópia para **`terraform.tfvars`**. (É importante que seja exatamente esse nome, sem o `.example`).
    * Abra o arquivo `terraform.tfvars` (o novo, sem o `.example`) com um editor de texto.
    * Preencha os valores das variáveis com suas informações:

        ```terraform
        aws_region           = "us-east-1" # Mantenha ou altere para a região AWS de sua preferência (ex: "sa-east-1" para São Paulo)
        instance_type        = "t2.medium" # Tipo de servidor. Pode começar com "t2.micro" para economizar se for Free Tier, mas "t2.medium" é mais robusto.
        ami_id               = "ami-053b0dcd10dcfd54e" # ID da imagem do Ubuntu Server 22.04 LTS em us-east-1. Se mudar a região, precisará de outro AMI ID. Você pode encontrar no console EC2 > AMIs.
        key_name             = "minha-chave-infrastack" # O NOME da chave SSH que você criou na AWS (sem o .pem)
        vpc_cidr_block       = "10.0.0.0/16"
        public_subnet_cidr_block = "10.0.1.0/24"
        ```

    * **Salve as alterações** no arquivo `terraform.tfvars`.

---

## 🚀 Hora da Implantação!

Com tudo configurado, você está pronto para mandar o Terraform criar sua infraestrutura.

1.  **Inicialize o Terraform:** No seu terminal, certifique-se de estar na pasta principal do projeto (`infrastack`). Execute o comando:

    ```bash
    terraform init
    ```

    Este comando baixa os plugins necessários para o Terraform se comunicar com a AWS. Você verá mensagens como "Terraform has been successfully initialized!".

2.  **Planeje a Implantação:** Antes de criar qualquer coisa, o Terraform pode mostrar o que ele vai fazer.

    ```bash
    terraform plan
    ```

    Ele listará todos os recursos que serão criados, modificados ou destruídos. Verifique se faz sentido para você (você verá itens como `+ aws_instance.infrastack_server`, `+ aws_security_group.instance_sg`, etc.).

3.  **Aplique as Mudanças:** Se o plano parecer correto, é hora de criar a infraestrutura.

    ```bash
    terraform apply
    ```

    O Terraform perguntará se você quer realmente aplicar as mudanças. Digite `yes` e pressione Enter.
    Aguarde. Este processo pode levar alguns minutos, pois o Terraform estará criando o servidor, configurando a rede, instalando Docker e rodando os containers.

---

## ✅ Verifique a Implantação

Quando o `terraform apply` terminar, ele exibirá as "Saídas" (Outputs). É aqui que você encontra as informações para acessar suas ferramentas:


---

Outputs:

* glpi_url = "http://XX.XX.XX.XX/glpi"
* grafana_url = "http://XX.XX.XX.XX:3000"
* portainer_url = "http://XX.XX.XX.XX:9000"
* public_ip = "XX.XX.XX.XX"
* ssh_command = "ssh -i ~/.ssh/minha-chave-infrastack.pem ubuntu@XX.XX.XX.XX"
* zabbix_url = "http://XX.XX.XX.XX:8080"

---


* **`public_ip`:** Este é o endereço IP público do seu novo servidor.
* **`ssh_command`:** Você pode usar este comando no seu terminal para acessar o servidor via SSH (substitua `~/.ssh/minha-chave-infrastack.pem` pelo caminho completo do arquivo `.pem` da sua chave SSH, se ele não estiver na pasta padrão).
* **`glpi_url`, `zabbix_url`, `grafana_url`, `portainer_url`:** Copie esses URLs e cole-os no seu navegador. Você deverá conseguir acessar as interfaces web das ferramentas!
    * **Primeiro acesso ao Portainer:** Você será solicitado a criar um usuário e senha admin.
    * **Primeiro acesso ao GLPI:** Siga o assistente de instalação. Use os dados do banco de dados que você configurou no `docker-compose.yml` (e alterou no `install_docker.sh`).
    * **Primeiro acesso ao Zabbix:** O login padrão geralmente é `Admin` com senha `zabbix`.
    * **Primeiro acesso ao Grafana:** O login padrão geralmente é `admin` com senha `admin`. Será pedido para você mudar a senha no primeiro login.

---

## 🗑️ Como Deletar a Infraestrutura (Importante para Economia!)

Para evitar custos desnecessários na AWS, quando você não precisar mais da infraestrutura, pode deletar tudo que o Terraform criou com um único comando:

```bash
terraform destroy
Ele pedirá confirmação. Digite yes e pressione Enter. O Terraform removerá todos os recursos que ele provisionou na sua conta AWS.
