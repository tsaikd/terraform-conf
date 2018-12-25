variable "name" {
  default = "test"
}

variable "ssh-pub-key" {
  default = "id_rsa.pub"
}

variable "ssh-key" {
  default = "id_rsa"
}

variable "project" {
  default = "example-project-2019"
}

variable "region" {
  default = "asia-east1"
}

variable "zone" {
  default = "asia-east1-a"
}

variable "username" {
  default = "user"
}

variable "network_name" {
  default = "default"
}

variable "machine_type" {
  default = "g1-small"
}

variable "image" {
  default = "centos-cloud/centos-7"
}
