terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "google" {
  project = var.project_id
  # If needed, also specify region or credentials here.
}

locals {
  image_map = {
    "stable" = "flatcar-stable-3227-2-2"
    "beta"   = "flatcar-beta-3277-1-2"
    "alpha"  = "flatcar-alpha-3346-0-0"
  }

  # Construct the full image path (like DM's "https://www.googleapis.com/compute/v1/projects/kinvolk-public/global/images/<IMAGE>")
  flatcar_image = "projects/kinvolk-public/global/images/${lookup(local.image_map, var.channel, "flatcar-stable-3227-2-2")}"

  # A single external IP from the array
  # (In DM you can have multiple, but let's just take the first for this example.)
  external_ip = length(var.external_ip) > 0 ? var.external_ip[0] : null

  # Does the user want a real external IP, ephemeral, or none?
  has_external_ip = (
    local.external_ip != null &&
    local.external_ip != "NONE"
  )

  # Terraform's boolean for canIpForward
  can_ip_forward = (lower(var.ip_forward) == "on") ? true : false
}

resource "google_compute_instance" "flatcar_vm" {
  name         = var.goog_cm_deployment_name
  zone         = var.zone
  machine_type = var.machine_type
  can_ip_forward = local.can_ip_forward

  boot_disk {
    initialize_params {
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
      image = local.flatcar_image
    }
  }

  # If your DM config allowed multiple networks/subnetworks,
  # you can handle them with dynamic blocks.
  # For simplicity, we attach only the first network/subnetwork:
  network_interface {
    network    = length(var.network) > 0 ? var.network[0] : "default"
    subnetwork = length(var.subnetwork) > 0 ? var.subnetwork[0] : null

    # If the user wants ephemeral or a static IP, set it. If "NONE", no external interface
    access_config {
      nat_ip = local.has_external_ip && local.external_ip != "EPHEMERAL" ? local.external_ip : null
    }
  }

  service_account {
    email  = "default"
    scopes = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  tags = [ "${var.deployment_name}-deployment" ]
}
