resource "kubernetes_pod" "default" {
  metadata {
    name = "${var.name}"
    labels {
      app = "${var.name}"
    }
  }

  spec {
    container {
      image = "${var.image}"
      name  = "${var.name}"
      command = ["sleep", "3600"]
      resources {
        requests {
          cpu = "1m"
        }
      }
      env {
        name = "POD_IP"
        value_from {
          field_ref {
            field_path = "status.podIP"
          }
        }
      }
      env {
        name = "NODE_IP"
        value_from {
          field_ref {
            field_path = "status.hostIP"
          }
        }
      }
    }
  }
}
