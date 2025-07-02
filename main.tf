provider "google" {
  project = var.project_id
  # If needed, also specify region or credentials here.
}

locals {
  image_map = {
    "stable" = "flatcar-stable-4320-2-0"
    "beta"   = "flatcar-beta-4244-1-0"
    "alpha"  = "flatcar-alpha-4372-0-0"
  }

  flatcar_image = var.flatcar_image == "" ?  "projects/kinvolk-public/global/images/${lookup(local.image_map, var.channel, "flatcar-stable-4320-2-0")}" : var.flatcar_image

  external_ip = length(var.external_ip) > 0 ? var.external_ip[0] : null

  has_external_ip = (
    local.external_ip != null &&
    local.external_ip != "NONE"
  )

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

  network_interface {
    network    = length(var.network) > 0 ? var.network[0] : "default"
    subnetwork = length(var.subnetwork) > 0 ? var.subnetwork[0] : null

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
