output "ssh_public_key" {
  value       = resource.tls_private_key.tls_key.public_key_openssh
  description = "SSH Public Key"
}
