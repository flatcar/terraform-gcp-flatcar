variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

// Marketplace requires this variable name to be declared
variable "goog_cm_deployment_name" {
  description = "The name of the deployment and VM instance."
  type        = string
}

variable "zone" {
  type        = string
  description = "GCP zone to deploy the VM."
  default     = "us-central1-a"
}

variable "channel" {
  type        = string
  description = "Flatcar channel (e.g. stable, beta, alpha)."
  default     = "stable"
}

variable "machine_type" {
  type        = string
  description = "Compute Engine machine type (e.g., e2-medium, n2-standard-2)."
  default     = "n2-standard-2"
}

variable "network" {
  type        = list(string)
  description = "List of network names (default is ['default'])."
  default     = ["default"]
}

variable "subnetwork" {
  type        = list(string)
  description = "List of subnetworks (optional)."
  default     = []
}

variable "external_ip" {
  type        = list(string)
  description = "List containing external IP addresses (e.g. [EPHEMERAL], [NONE], etc.)."
  default     = ["EPHEMERAL"]
}

variable "ip_forward" {
  type        = string
  description = "IP forwarding: On or Off."
  default     = "Off"
}

variable "boot_disk_type" {
  type        = string
  description = "Boot disk type (e.g., pd-ssd, pd-standard, etc.)."
  default     = "pd-ssd"
}

variable "boot_disk_size_gb" {
  type        = number
  description = "Boot disk size in GB."
  default     = 10
}

variable "deployment_name" {
  type        = string
  description = "Name prefix for your deployment."
  default     = "flatcar"
}

variable "flatcar_image" {
  type        = string
  description = "Absolute Flatcar Image URL"
  default     = "projects/kinvolk-public/global/images/flatcar-stable-4230-2-0"
}
