# variables.tf — All configurable values in one place

variable "namespace" {
  description = "Kubernetes namespace for your team"
  type        = string
}

variable "team_name" {
  description = "Human-readable team name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "POSTGRES_USER" {
  description = "Admin användare"
  type        = string
} 

variable "POSTGRES_DB" {
  description = "Namn på databas"
  type		  = string
}

variable "POSTGRES_PASSWORD" {
  description = "Admin Lösenord"
  type	      = string
}

variable "api_image" {
  description = "api container image"
  type        = string
  default     = "danielwchas/dice-app:v7"
}

variable "db_image" {
  description = "DB container image"
  type        = string
  default     = "postgres:15"
}

variable "api_replicas" {
  description = "Number of API replicas"
  type        = number
  default     = 1
}

variable "db_replicas" {
  description = "Number of db replicas"
  type		  = number
  default	  = 1
}
