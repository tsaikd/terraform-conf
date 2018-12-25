resource "kubernetes_stateful_set" "discovery" {
  metadata {
    name = "${var.name}-discovery"
    labels {
      app = "${var.name}"
      role = "discovery"
    }
  }

  spec {
    selector {
      match_labels {
        app = "${var.name}"
        role = "discovery"
      }
    }

    service_name = "${var.name}-discovery"
    replicas = 1

    template {
      metadata {
        labels {
          app = "${var.name}"
          role = "discovery"
        }
      }

      spec {
        init_container {
          name = "init-data-permission"
          image = "busybox"
          command = ["chown", "1000:1000", "/usr/share/elasticsearch/data"]
          volume_mount {
            name = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }
        container {
          image = "${var.image}"
          name  = "${var.name}"
          command = ["sh", "-c", "ulimit -l unlimited && exec su elasticsearch docker-entrypoint.sh"]
          resources {
            requests {
              cpu = "1m"
            }
          }
          env {
            name = "cluster.name"
            value = "${var.name}"
          }
          env {
            name = "bootstrap.memory_lock"
            value = "true"
          }
          env {
            name = "ES_JAVA_OPTS"
            value = "${var.javaopt}"
          }
          security_context {
            privileged = "true"
            capabilities {
              add = ["IPC_LOCK", "SYS_RESOURCE"]
            }
          }
          port {
            name = "http"
            container_port = "9200"
          }
          port {
            name = "transport"
            container_port = "9300"
          }
          readiness_probe {
            http_get {
              path = "/_cluster/health"
              port = "http"
            }
            initial_delay_seconds = 30
            period_seconds = 10
          }
          volume_mount {
            name = "data"
            mount_path = "/usr/share/elasticsearch/data"
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
            storage = "1Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_stateful_set" "data" {
  metadata {
    name = "${var.name}-data"
    labels {
      app = "${var.name}"
      role = "data"
    }
  }

  spec {
    selector {
      match_labels {
        app = "${var.name}"
        role = "data"
      }
    }

    service_name = "${var.name}"
    replicas = 2
    pod_management_policy = "Parallel"

    template {
      metadata {
        labels {
          app = "${var.name}"
          role = "data"
        }
      }

      spec {
        init_container {
          name = "init-data-permission"
          image = "busybox"
          command = ["chown", "1000:1000", "/usr/share/elasticsearch/data"]
          volume_mount {
            name = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }
        init_container {
          name = "wait-for-discovery-node"
          image = "tutum/curl"
          command = ["sh", "-c", "while true; do curl http://${var.name}-discovery:9200/_cluster/health && exit 0 ; sleep 5 ; done"]
        }
        container {
          image = "${var.image}"
          name  = "${var.name}"
          command = ["sh", "-c", "ulimit -l unlimited && sysctl -w vm.max_map_count=262144 && exec su elasticsearch docker-entrypoint.sh"]
          resources {
            requests {
              cpu = "1m"
            }
          }
          env {
            name = "cluster.name"
            value = "${var.name}"
          }
          env {
            name = "bootstrap.memory_lock"
            value = "true"
          }
          env {
            name = "ES_JAVA_OPTS"
            value = "${var.javaopt}"
          }
          env {
            name = "discovery.zen.ping.unicast.hosts"
            value = "${var.name}-discovery"
          }
          security_context {
            privileged = "true"
            capabilities {
              add = ["IPC_LOCK", "SYS_RESOURCE"]
            }
          }
          port {
            name = "http"
            container_port = "9200"
          }
          port {
            name = "transport"
            container_port = "9300"
          }
          readiness_probe {
            http_get {
              path = "/_cluster/health"
              port = "http"
            }
            initial_delay_seconds = 30
            period_seconds = 10
          }
          volume_mount {
            name = "data"
            mount_path = "/usr/share/elasticsearch/data"
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
            storage = "1Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "discovery" {
  metadata {
    name = "${var.name}-discovery"
    labels {
      app = "${var.name}"
      role = "discovery"
    }
  }
  spec {
    selector {
      app = "${var.name}"
      role = "discovery"
    }

    port {
      name = "data"
      port = 9200
      target_port = 9200
    }
    port {
      name = "discovery"
      port = 9300
      target_port = 9300
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "data" {
  metadata {
    name = "${var.name}"
    labels {
      app = "${var.name}"
      role = "data"
    }
  }
  spec {
    selector {
      app = "${var.name}"
      role = "data"
    }

    port {
      port = 9200
      target_port = 9200
    }

    type = "ClusterIP"
  }
}
