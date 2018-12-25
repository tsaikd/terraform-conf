resource "google_compute_network" "default" {
  count = "${var.network_name == "default" ? 0 : 1}"
  name = "${var.network_name}"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "mosh" {
  name = "${var.name}"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  allow {
    protocol = "udp"
    ports = ["60001-60005"]
  }

  target_tags = ["mosh"]
}

resource "google_compute_instance" "default" {
  name = "${var.name}"
  machine_type = "${var.machine_type}"
  zone = "${var.zone}"

  tags = ["mosh"]

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    network = "${var.network_name}"

    access_config {}
  }

  metadata {
    sshKeys = "${var.username}:${file("${var.ssh-pub-key}")}"
  }
  metadata_startup_script = "date >> /tmp/startup.log"

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "${var.username}"
      private_key = "${file("${var.ssh-key}")}"
    }
    inline = [
      "sudo yum install -y mosh",
    ]
  }
}

output "ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}
