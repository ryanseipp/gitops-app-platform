# Variables for bootstrapping tailscale in-cluster
variable "tailscale_oauth_client_id" {
  type        = string
  description = "The Tailscale OAuth application's ID."
}

variable "tailscale_oauth_client_secret" {
  type        = string
  sensitive   = true
  description = "The Tailscale OAuth application's secret."
}
