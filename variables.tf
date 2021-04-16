variable project {}
variable region {}
variable k8s_subnet {}
variable k8s_controllers {}
variable k8s_controller_zones {
    type = map(string)
}
variable k8s_controller_ip_int_addresses {
    type = map(string)
}
variable ssh_username {}
variable ssh_pubkey_path {
    type = string
    default = "~/.ssh/id_rsa.pub"
}