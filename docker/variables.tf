variable "container_name" {
  description = "Value of the name for the Docker container"
  type        = string
  default     = "ExampleNginxContainer"
}

variable "ext_port" {
  default = "1880"
  description = "external port"
  
  validation {
    condition = var.ext_port <= 65535 && var.ext_port > 0
    error_message = "The external port must be int the valid port range 0 - 65535"
  }
}

variable "int_port" {
  default = "1880"
  type = number
  description = "internal port"

  validation {
    condition = var.int_port == 1880
    error_message = "The internal port must be 1880"
  }
}