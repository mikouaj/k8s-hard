provider "google" {
  project = var.project
  region  = var.region
}

locals {
  ssh_pubkey = file(var.ssh_pubkey_path)
}

data "google_compute_zones" "available" {
  region = var.region
}

resource "google_compute_network" "backend" {
  name                    = "backend"
  description             = "network for backend systems"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "backend-k8s" {
  name          = "k8s"
  description   = "kubernetes cluster"
  ip_cidr_range = var.k8s_subnet
  region        = var.region
  network       = google_compute_network.backend.id
}

resource "google_compute_firewall" "backend-internal" {
  name          = "backend-internal"
  network       = google_compute_network.backend.id
  source_ranges = [var.k8s_subnet]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}

resource "google_compute_firewall" "backend-external" {
  name          = "backend-external"
  network       = google_compute_network.backend.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }
}

resource "google_compute_instance" "k8s-controller" {
  for_each = toset(var.k8s_controllers)
  name         = "k8s-${each.key}"
  machine_type = "e2-standard-2"
  zone         = var.k8s_controller_zones[each.key]
  tags         = ["kubernetes-the-hard-way", "controller"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }
  can_ip_forward = true
  network_interface {
    subnetwork = google_compute_subnetwork.backend-k8s.name
    network_ip = var.k8s_controller_ip_int_addresses[each.key]
    access_config {
    }
  }
  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring"
    ]
  }
  metadata = {
    ssh-keys = "${var.ssh_username}:${local.ssh_pubkey}"
  }
}
