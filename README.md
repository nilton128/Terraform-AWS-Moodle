# Terraform AWS EC2 Instance Setup

Este repositório contém um script Terraform para provisionar uma instância EC2 da AWS utilizando uma AMI do Ubuntu mais recente. O script também configura um grupo de segurança para permitir tráfego SSH e HTTP, e executa um script de inicialização para instalar Docker e configurar contêineres do Moodle e MariaDB.


## Pré-requisitos

- Terraform instalado
- Credenciais AWS configuradas
- Uma chave SSH existente na AWS


O Moodle estará disponível na porta 8080 após a instância ser provisionada.

