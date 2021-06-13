variable "location" {
  type    = string
  default = "West US 2"
}

variable "prefix" {
  type    = string
  default = "azure"
}

variable "zones" {
  type    = list(string)
  default = [1, 2, 3]
}

variable "password" {
  type    = string
}
