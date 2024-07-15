# Obtém a AMI mais recente do Ubuntu 20.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Cria a VPC
resource "aws_vpc" "new_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "new_vpc"
  }
}

# Cria o Internet Gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.new_vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

# Cria a sub-rede pública
resource "aws_subnet" "new_subnet_public" {
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "new_subnet_public"
  }
}

# Associa o Internet Gateway à tabela de rotas da VPC
resource "aws_route" "route_internet_gateway" {
  route_table_id         = aws_vpc.new_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example_igw.id
}

# Grupo de Segurança para permitir tráfego SSH e HTTP
resource "aws_security_group" "permitir_ssh_http" {
  name        = "permitir_ssh_http"
  description = "Allow SSH and HTTP on EC2 instance"
  vpc_id      = aws_vpc.new_vpc.id

  ingress {
    description = "SSH to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP to EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP 8080 to EC2"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "permitir_ssh_e_http"
  }
}

# Cria a instância EC2
resource "aws_instance" "new_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "nil" # Insira o nome da chave criada antes.
  subnet_id                   = aws_subnet.new_subnet_public.id
  vpc_security_group_ids      = [aws_security_group.permitir_ssh_http.id]
  associate_public_ip_address = true
  user_data                   = file("file.sh")
  iam_instance_profile        = "Ec2AgenteSSM"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Habilita IMDSv2 obrigatório
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  tags = {
    Name = "Server01-Terraform"
    # Insira o nome da instância de sua preferência.
  }
}

# Saída do IP público da instância EC2
output "ec2_public_ip" {
  description = "O endereço IP público da instância EC2"
  value       = aws_instance.new_ec2.public_ip
}
bbb