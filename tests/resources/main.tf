resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
