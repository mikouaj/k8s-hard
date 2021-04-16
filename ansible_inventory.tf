data "template_file" "ansible_inventory_k8s_cluster" {
  template = file("ansible/tpl/inventory/k8s-cluster.tpl.yml")
  vars = {
    ansible_user = var.ssh_username
  }
}

resource "null_resource" "ansible_inventory_k8s_cluster" {
  triggers = {
    template_rendered = data.template_file.ansible_inventory_k8s_cluster.rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_inventory_k8s_cluster.rendered}' > 'ansible/inventory/k8s-cluster.yml'"
  }
}

data "template_file" "ansible_inventory_k8s_controllers" {
  for_each = toset(var.k8s_controllers)
  template = file("ansible/tpl/inventory/host_vars/k8s-controller.tpl.yml")
  vars = {
    k8s-controller = each.key
    ip_ext_address = google_compute_instance.k8s-controller[each.key].network_interface[0].access_config[0].nat_ip
    ip_int_address = var.k8s_controller_ip_int_addresses[each.key]
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