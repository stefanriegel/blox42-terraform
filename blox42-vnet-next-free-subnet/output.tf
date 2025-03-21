output "infoblox_api_debug" {
  value = jsondecode(jsonencode(data.bloxone_ipam_next_available_subnets.example_tf_subs))
}