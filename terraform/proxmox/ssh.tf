data "curl" "github_ssh_pub_keys" {
  http_method = "GET"
  uri         = "https://github.com/codecio.keys"
}

locals {
  ssh_pub_keys = data.curl.github_ssh_pub_keys.response
}
