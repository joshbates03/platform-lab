resource "google_container_cluster" "gke" {
  name     = "platform-lab-dev-gke"
  location = var.zone

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
  release_channel {
    channel = "REGULAR"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  location   = google_container_cluster.gke.location
  cluster    = google_container_cluster.gke.name
  node_count = 1

  node_config {
    machine_type = "e2-standard-2"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
