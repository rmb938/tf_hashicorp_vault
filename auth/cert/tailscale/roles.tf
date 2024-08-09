resource "vault_cert_auth_backend_role" "cert" {
  name                 = "foo"
  certificate          = file("./le_isrg_root_x2.pem")
  backend              = vault_auth_backend.cert.path
  allowed_common_names = ["foo.example.org"]
  display_name         = ""
  token_policies       = ["default"]
  token_bound_cidrs    = [""]
}
