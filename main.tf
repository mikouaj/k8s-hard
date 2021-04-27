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
  source_ranges = [var.k8s_subnet, "10.200.0.0/16"]
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

resource "google_compute_firewall" "backend-healthcheck" {
  name          = "backend-healthcheck"
  network       = google_compute_network.backend.id
  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
}

resource "google_compute_address" "k8s-address" {
  name   = "kubernetes-cluster"
  region = var.region
}

resource "google_compute_route" "k8s-worker-podsubnet" {
  for_each = toset(var.k8s_workers)
  depends_on = [
    google_compute_subnetwork.backend-k8s
  ]
  name        = "k8s-podsubnet-${replace(var.k8s_worker_pod_cidrs[each.key], "/[.//]/", "-")}"
  network     = google_compute_network.backend.id
  next_hop_ip = var.k8s_worker_ip_int_addresses[each.key]
  dest_range  = var.k8s_worker_pod_cidrs[each.key]
}

resource "google_compute_instance" "k8s-controller" {
  for_each     = toset(var.k8s_controllers)
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
    VmDnsSetting = "GlobalDefault"
  }
}

resource "google_compute_instance" "k8s-worker" {
  for_each     = toset(var.k8s_workers)
  name         = "k8s-${each.key}"
  machine_type = "e2-standard-2"
  zone         = var.k8s_worker_zones[each.key]
  tags         = ["kubernetes-the-hard-way", "worker"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }
  can_ip_forward = true
  network_interface {
    subnetwork = google_compute_subnetwork.backend-k8s.name
    network_ip = var.k8s_worker_ip_int_addresses[each.key]
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
    pod-cidr = var.k8s_worker_pod_cidrs[each.key]
    VmDnsSetting = "GlobalDefault"
  }
}

resource "google_compute_http_health_check" "k8s" {
  name         = "k8s"
  description  = "Kubernetes Health Check"
  request_path = "/healthz"
  host         = "kubernetes.default.svc.cluster.local"
}

resource "google_compute_target_pool" "k8s" {
  name = "k8s"
  instances = [
    for k8s-controller in google_compute_instance.k8s-controller :
    "${k8s-controller.zone}/${k8s-controller.name}"
  ]
  health_checks = [
    google_compute_http_health_check.k8s.name
  ]
}

resource "google_compute_forwarding_rule" "k8s" {
  name       = "k8s"
  region     = var.region
  ip_address = google_compute_address.k8s-address.address
  port_range = 6443
  target     = google_compute_target_pool.k8s.id
}
