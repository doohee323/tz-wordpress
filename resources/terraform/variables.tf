variable "region" {
    type = string
    default = "asia-northeast3-a"
}
variable "project" {
    type = string
    default = "constant-tracer-224322"
}
variable "user" {
    type = string
}
variable "email" {
    type = string
    default = "dh-serviceaccount@constant-tracer-224322.iam.gserviceaccount.com"
}
variable "privatekeypath" {
    type = string
    default = "~/.ssh/constant-tracer-224322"
}
variable "publickeypath" {
    type = string
    default = "~/.ssh/constant-tracer-224322.pub"
}
