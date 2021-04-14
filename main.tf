provider "google" {
  project = var.project
  region  = var.region
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
