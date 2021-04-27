project         = "hedgehog-310710"
region          = "europe-central2"
k8s_subnet      = "10.69.1.0/24"
k8s_controllers = ["controller1", "controller2", "controller3"]
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
k8s_workers = ["worker1", "worker2", "worker3"]
k8s_worker_zones = {
  worker1 = "europe-central2-a"
  worker2 = "europe-central2-b"
  worker3 = "europe-central2-c"
}
k8s_worker_ip_int_addresses = {
  worker1 = "10.69.1.20"
  worker2 = "10.69.1.21"
  worker3 = "10.69.1.22"
}
k8s_worker_pod_cidrs = {
  worker1 = "10.200.0.0/24"
  worker2 = "10.200.1.0/24"
  worker3 = "10.200.2.0/24"
}
ssh_username = "nick"