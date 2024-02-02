output "vm_name" {
  value       = {
    for k, vm in libvirt_domain.vm : k => format("%s/%s",vm.name,vm.network_interface[0].addresses.0)
  }
  description = "VM name"
}

#  output "vm_ip" {
# #   count = length(var.domains)
#    value       = {
#     for k, vm in libvirt_domain.vm : k => vm.network_interface[0].addresses.0
#    }
#    description = "Interface IPs"
# }