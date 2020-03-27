provider "docker" {
   version = "2.7.0"
   host = "unix:///var/run/docker.sock"
}

// some randomness so we can create two of these clusters at once if necessary
resource "random_string" "cluster_id" {
  length = 4
  special = false
  upper = false
}

locals {
   cluster_id = random_string.cluster_id.result
}

resource "docker_network" "consul_network" {
   name = "consul-adoption-day-${local.cluster_id}"
   check_duplicate = "true"
   driver = "bridge"
   options = {
      "com.docker.network.bridge.enable_icc" = "true"
      "com.docker.network.bridge.enable_ip_masquerade" = "true"
   }
   internal = false
}

resource "docker_image" "consul" {
   name = var.consul_image
   keep_locally = true
}

// module "servers" {
//    source = "../modules/servers"

//    persistent_data = true
//    datacenter = "primary"
//    default_networks = [docker_network.consul_network.name]
//    default_image = docker_image.consul.name
//    default_name_include_dc = false
//    default_name_suffix = "-${local.cluster_id}"

//    # 3 servers all with defaults
//    servers = [{},{},{}]
// }

variable "consul_http_port" {
   type = number
   default = 8500
   description = "Port to map Consul's HTTP API to on the host"
}

module "clients" {
   source = "../modules/clients"
   default_networks = [docker_network.consul_network.name]
   // default_image = docker_image.consul.name
   default_image = "consul:latest"
   // extra_args = module.servers.join
   extra_args = ["-dev"]

   clients = [
      {
         "name": "consul-ui-${local.cluster_id}",
         "extra_args": ["-ui"],
         "ports": {
            "http": {
               "internal": 8500,
               "external": var.consul_http_port,
               "protocol": "tcp",
            },
            "dns": {
               "internal": 8600,
               "external": 8600,
               "protocol": "udp",
            },
         }
      }
   ]
}