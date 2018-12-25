resource "kubernetes_deployment" "default" {
  metadata {
    name = "${var.name}"
    labels {
      app = "${var.name}"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels {
        app = "${var.name}"
      }
    }

    template {
      metadata {
        labels {
          app = "${var.name}"
        }
      }

      spec {
        container {
          image = "${var.image}"
          name  = "${var.name}"
          resources {
            requests {
              cpu = "1m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "default" {
  metadata {
    name = "${var.name}"
    labels {
      app = "${var.name}"
    }
  }
  spec {
    selector {
      app = "${kubernetes_deployment.default.metadata.0.labels.app}"
    }

    # session_affinity = "ClientIP"
    port {
      name = "http"
      port = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}
