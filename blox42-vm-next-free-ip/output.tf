output "vm_private_ip" {
  value = data.bloxone_ipam_next_available_ips.next_vm_ip.results[0]
}

output "infoblox_dns_record" {
  value = bloxone_dns_a_record.vm_dns_record.absolute_name_spec
}