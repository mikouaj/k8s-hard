project = "hedgehog-310710"
region = "europe-central2"
k8s_subnet = "10.69.1.0/24"
//k8s_controllers = ["controller1", "controller2", "controller3"]
k8s_controllers = ["controller1"]
k8s_controller_zones = {
    controller1 = "europe-central2-a"
    controller2 = "europe-central2-b"
    controller3 = "europe-central2-c"
}
k8s_controller_ip_int_addresses = {
    controller1 = "10.69.1.10"
    controller2 = "10.69.1.11"
    controller3 = "10.69.1.12"
}
ssh_username = "nick"