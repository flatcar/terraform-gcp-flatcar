output "deployment" {
  description = "Name of the deployment (for reference)."
  value       = var.deployment_name
}

output "vm_name" {
  description = "Name of the VM."
  value       = google_compute_instance.flatcar_vm.name
}

output "vm_self_link" {
  description = "Self link of the VM."
  value       = google_compute_instance.flatcar_vm.self_link
}

output "vm_zone" {
  description = "Zone of the VM."
  value       = google_compute_instance.flatcar_vm.zone
}

output "vm_external_ip" {
  description = "External IP if assigned, or NONE."
  value       = local.has_external_ip ? google_compute_instance.flatcar_vm.network_interface[0].access_config[0].nat_ip : "NONE"
}

output "vm_internal_ip" {
  description = "Internal IP of the VM."
  value       = google_compute_instance.flatcar_vm.network_interface[0].network_ip
}

output "vm_id" {
  description = "Unique ID of the VM."
  value       = google_compute_instance.flatcar_vm.id
}
