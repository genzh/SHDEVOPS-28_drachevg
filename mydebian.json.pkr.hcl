packer {
  required_plugins {
    yandex = {
      version = ">= 1.0.7"
      source  = "github.com/hashicorp/yandex"
    }
  }
}

variable "folder_id" {
  type    = string
  default = "b1gge5ajntjsps7j1p29"
}

variable "subnet" {
  type    = string
  default = "e9bl8fu36inekr1a98l9"
}

variable "token" {
  type    = string
  default = "xxxxx" 
}

source "yandex" "debian" {
  folder_id           = var.folder_id
  subnet_id           = var.subnet
  source_image_family = "debian-11"
  ssh_username        = "debian"
  use_ipv4_nat        = true
  disk_type           = "network-ssd"
  disk_size           = 15
  cores               = 2
  memory              = 2
  platform_id         = "standard-v3"
  token               = var.token
}

build {
  sources = ["source.yandex.debian"]

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "apt-get install -y ca-certificates curl gnupg lsb-release",
      "install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",
      "chmod a+r /etc/apt/keyrings/docker.asc",
      "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get update",
      "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin htop tmux",
      "usermod -aG docker debian",
      "systemctl enable --now docker"
    ]
  }

  post-processor "manifest" {}
}