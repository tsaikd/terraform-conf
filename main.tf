# provider "google" {
#   credentials = "${file("CREDENTIALS.JSON")}"
#   project     = "PROJECT-ID-2019"
#   region      = "ASIA-EAST1"
# }

# provider "kubernetes" {}

# module "curl" {
#   source = "curl/kubernetes"
# }

# module "nginx" {
#   source = "nginx/kubernetes"
# }

# module "redis" {
#   source = "redis/kubernetes"
# }

# module "gitlab" {
#   source = "gitlab/kubernetes"
# }

# module "elasticsearch" {
#   source = "elasticsearch/kubernetes"
# }

# module "mosh-gce" {
#   source       = "mosh/gce"
#   name         = "test-mosh"
#   ssh-pub-key  = "id_ed25519.pub"
#   ssh-key      = "id_ed25519"
#   project      = "PROJECT-ID-2019"
#   region       = "ASIA-EAST1"
#   zone         = "ASIA-EAST1-A"
#   network_name = "default"
#   username     = "user"
# }

# output "mosh-ip" {
#   value = "${module.mosh-gce.ip}"
# }
