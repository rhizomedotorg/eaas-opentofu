variable "script" {
  default = ""
}

variable "env" {
  default = {}
}

output "user_data" {
  value = <<-EOF
  ${split("\n", file(var.script))[0]}
  %{for k, v in var.env}export '${replace("${k}=${v}", "'", "'\\''")}'
  %{endfor}
  ${file(var.script)}
  EOF
}
