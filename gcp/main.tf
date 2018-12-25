resource "google_compute_network" "default" {
  name = "${var.network_name}"
  auto_create_subnetworks = "true"
}

resource "google_container_cluster" "default" {
  name = "${var.cluster_name}"
  zone = "${var.zone}"
  network = "${var.network_name}"
  lifecycle {
    ignore_changes = ["node_pool"]
  }
  node_pool {
    name = "default-pool"
  }
  # enable_legacy_abac = true
}

resource "google_container_node_pool" "default" {
  name = "${var.cluster_name}"
  zone = "${var.zone}"
  cluster = "${var.cluster_name}"
  node_count = 1
  node_config {
    machine_type = "${var.machine_type}"
  }
}
