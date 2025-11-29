variable "project_name" {
  description = "Nombre lógico del proyecto (prefijo para recursos)."
  type        = string
  default     = "portfolio-devops"
}

variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura."
  type        = string
  default     = "us-west-2"
}

variable "site_bucket_name" {
  description = "Nombre del bucket S3 para el sitio estático (debe ser único a nivel global)."
  type        = string
}

variable "github_repository_url" {
  description = "URL HTTPS del repositorio de GitHub."
  type        = string
  default     = "https://github.com/Julayo/portfolio-devops.git"
}

variable "tags" {
  description = "Tags adicionales para aplicar a los recursos."
  type        = map(string)
  default     = {}
}
