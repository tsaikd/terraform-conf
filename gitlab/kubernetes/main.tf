resource "kubernetes_persistent_volume_claim" "config" {
  metadata {
    name = "${var.name}-config"
    labels {
      app = "${var.name}"
      role = "config"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests {
        storage = "10Mi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "data" {
  metadata {
    name = "${var.name}-data"
    labels {
      app = "${var.name}"
      role = "data"
    }
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

resource "kubernetes_persistent_volume_claim" "log" {
  metadata {
    name = "${var.name}-log"
    labels {
      app = "${var.name}"
      role = "log"
    }
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
      env {
        name = "GITLAB_ONIBUS_CONFIG"
        value = ""
      }
      volume_mount {
        name = "config"
        mount_path = "/etc/gitlab"
      }
      volume_mount {
        name = "data"
        mount_path = "/var/opt/gitlab"
      }
      volume_mount {
        name = "log"
        mount_path = "/var/log/gitlab"
      }
    }
    volume {
      name = "config"
      persistent_volume_claim {
        claim_name = "${var.name}-config"
      }
    }
    volume {
      name = "data"
      persistent_volume_claim {
        claim_name = "${var.name}-data"
      }
    }
    volume {
      name = "log"
      persistent_volume_claim {
        claim_name = "${var.name}-log"
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
      app = "${var.name}"
    }

    # session_affinity = "ClientIP"
    port {
      name = "ssh"
      port = 22
      target_port = 22
    }
    port {
      name = "http"
      port = 80
      target_port = 80
    }
    port {
      name = "https"
      port = 443
      target_port = 443
    }

    type = "LoadBalancer"
  }
}
