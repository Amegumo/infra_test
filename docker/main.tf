# --- root/main.tf ---
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

// 乱数を使える様子
// 文字列4文字をランダムで生成
resource "random_string" "random" {
  count = 2
  length = 4
  special = false
  upper = false
}

provider "docker" {}

resource "null_resource" "dockervol" {
  provisioner "local-exec" {
    command = "mkdir -p noderedvol/  && sudo chown -R 1000:1000 noderedvol/"
  }
}
#resource "docker_image" "nodered_image" {
#  # docker image
#  name = "nodered/node-red:latest"
#}
#
#resource "docker_container" "nodered_container" {
#  count = length(random_string.random)
#  name = join("-", ["nodered", random_string.random[count.index].result])
#  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image#read-only
#  image = docker_image.nodered_image.image_id
#  ports {
#    internal = var.int_port
#    external = var.ext_port
#  }
#}
#