#output "container_id" {
#  description = "ID of the Docker container"
#  value = docker_container.nodered_container.id
#}

#output "image_id" {
#  description = "ID of the Docker image"
#  value = docker_image.nodered_image.id
#}
#output "to_address" {
#  description = "The net work data of the container"
#  value = docker_container.nodered_container[*].name
#}