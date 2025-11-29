variable "aws_region" {
  description = "Región principal de AWS para la infraestructura."
  type        = string
  default     = "us-west-2"
}

variable "site_bucket_name" {
  description = "Nombre del bucket S3 donde se aloja el sitio estático."
  type        = string
}

variable "project_name" {
  description = "Nombre lógico del proyecto."
  type        = string
  default     = "portfolio-devops"
}

variable "tags" {
  description = "Tags comunes para los recursos."
  type        = map(string)
  default = {
    Environment = "dev"
  }
}

# Dominio custom
variable "domain_name" {
  description = "Dominio del portfolio."
  type        = string
  default     = "julayo-dev.com"
}

variable "hosted_zone_id" {
  description = "Hosted Zone ID de Route 53 para el dominio."
  type        = string
  default     = "Z0305295VR3EQCJOGGXX"
}
