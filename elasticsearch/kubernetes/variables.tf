variable "name" {
  default = "test-elasticsearch"
}

variable "image" {
  default = "docker.elastic.co/elasticsearch/elasticsearch:6.5.4"
}

variable "javaopt" {
  default = "-Xms64m -Xmx64m"
}
