resource "kubernetes_config_map" "default" {
  metadata {
    name = "${var.name}"
  }
  data {
    start.sh = "${file("${path.module}/start.sh")}"
    redis.conf = "${file("${path.module}/redis.conf")}"
  }
}

resource "kubernetes_stateful_set" "default" {
  metadata {
    name = "${var.name}"
    labels {
      app = "${var.name}"
    }
  }

  spec {
    selector {
      match_labels {
        app = "${var.name}"
      }
    }

    service_name = "${var.name}"
    replicas = 3
    pod_management_policy = "Parallel"

    template = {
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
          port {
            container_port = 6379
          }
          port {
            container_port = 16379
          }
          resources {
            requests {
              cpu = "1m"
            }
          }
          volume_mount {
            name = "config"
            mount_path = "/conf"
          }
          volume_mount {
            name = "data"
            mount_path = "/data"
          }
          command = ["/conf/start.sh", "redis-server", "/conf/redis.conf"]
          liveness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 10
            period_seconds = 5
          }
          readiness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 10
            period_seconds = 5
          }
        }
        volume {
          name = "config"
          config_map {
            name = "${var.name}"
            default_mode = "0755"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests {
            storage = "100Mi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "default" {
  metadata {
    name = "in"
    labels {
      app = "${var.name}"
    }
  }
  spec {
    selector {
      app = "${var.name}"
    }
    port {
      name = "client"
      port = 6379
      target_port = 6379
    }
    port {
      name = "gossip"
      port = 16379
      target_port = 16379
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_service" "expose" {
  metadata {
    name = "${var.name}-expose"
    labels {
      app = "${var.name}"
    }
  }
  spec {
    selector {
      app = "${var.name}"
    }
    port {
      name = "client"
      port = 6379
      target_port = 6379
    }
    port {
      name = "gossip"
      port = 16379
      target_port = 16379
    }
    type = "ClusterIP"
  }
}
