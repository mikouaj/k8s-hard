data "template_file" "ansible_inventory_k8s_controllers" {
  for_each = toset(var.k8s_controllers)
  template = file("ansible/tpl/inventory/host_vars/k8s-controller.tpl.yml")
  vars = {
    ip_ext_address = google_compute_instance.k8s-controller[each.key].network_interface[0].access_config[0].nat_ip
    ip_int_address = var.k8s_controller_ip_int_addresses[each.key]
    ansible_user = var.ssh_username
  }
}

resource "null_resource" "ansible_inventory_k8s_controllers" {
  for_each = toset(var.k8s_controllers)
  triggers = {
    template_rendered = data.template_file.ansible_inventory_k8s_controllers[each.key].rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_inventory_k8s_controllers[each.key].rendered}' > 'ansible/inventory/host_vars/${each.key}.yml'"
  }
}

data "template_file" "ansible_inventory_k8s_workers" {
  for_each = toset(var.k8s_workers)
  template = file("ansible/tpl/inventory/host_vars/k8s-worker.tpl.yml")
  vars = {
    ip_ext_address = google_compute_instance.k8s-worker[each.key].network_interface[0].access_config[0].nat_ip
    ip_int_address = var.k8s_worker_ip_int_addresses[each.key]
    ansible_user = var.ssh_username
  }
}

resource "null_resource" "ansible_inventory_k8s_workers" {
  for_each = toset(var.k8s_workers)
  triggers = {
    template_rendered = data.template_file.ansible_inventory_k8s_workers[each.key].rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_inventory_k8s_workers[each.key].rendered}' > 'ansible/inventory/host_vars/${each.key}.yml'"
  }
}

data "template_file" "ansible_inventory_k8s_controllers_group" {
  template = file("ansible/tpl/inventory/group_vars/k8s-controllers.tpl.yml")
  vars = {
    ip_k8s_address = google_compute_address.k8s-address.address
  }
}

resource "null_resource" "ansible_inventory_k8s_controllers_group" {
  triggers = {
    template_rendered = data.template_file.ansible_inventory_k8s_controllers_group.rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_inventory_k8s_controllers_group.rendered}' > 'ansible/inventory/group_vars/k8s-controllers.yml'"
  }
}