# variables.tf — team-specific configuration

variable "namespace" {
  description = "Your team's Kubernetes namespace"
  type        = string
  # Replace with your namespace:
  default     = "the-hole"
}

variable "team_name" {
  description = "Your team's display name"
  type        = string
  default     = "the-hole"
}

variable "POSTGRES_USER" {
  description = "Namn på Admin User"
  type       = string
  default    = "daniel"
}
variable "POSTGRES_DB" {
  description = "Name på Databas"
  type       = string
  default    = "dicedb"
}
variable "POSTGRES_PASSWORD" {
  description = "Admin lösenord"
  type       = string
  default    = "d1c3_4pp_th3_h0l3_p455w0rd" 
}

