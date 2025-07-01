output "vm_private_ip" {
  value = bloxone_ipam_address.vm_ip.address
}

output "infoblox_dns_record" {
  value = bloxone_dns_a_record.vm_dns_record.absolute_name_spec
}