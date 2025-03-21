output "infoblox_dns_records" {
  value = [
    bloxone_dns_a_record.vm_dns_record_az.absolute_name_spec,
    bloxone_dns_a_record.vm_dns_record_aws.absolute_name_spec,
    bloxone_dns_a_record.vm_dns_record_gcp.absolute_name_spec
  ]
}