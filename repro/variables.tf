variable "consul_image" {
   type = string
   default = "consul:latest"
   description = "Name of the Consul container image to use"
}

// variable "consul_http_port" {
//    type = number
//    default = 8500
//    description = "Port to map Consul's HTTP API to on the host"
// }

variable "consul_dns_port" {
   type = number
   default = 8600
   description = "Port to map Consul's DNS to on the host"
}