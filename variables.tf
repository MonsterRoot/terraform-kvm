variable "domains" {
  description = "List of VMs with specified parameters"
  type = list(object({
    name = string,
    cpu  = number,
    ram  = number,
    disk = number
    # net = string
  }))
}

# Префикс для создаваемых объектов
variable "prefix" {
  type    = string
  default = "k0s-"
}

# Путь, где будет хранится пул проекта
variable "pool_path" {
  type    = string
  default = "/var/lib/libvirt/"
}

# Параметры облачного образа
variable "image" {
  type = object({
    name = string
    url  = string
  })
}

# Параметры виртуальной машины
# variable "vm" {
#   type = object({
#     cpu    = number
#     ram    = number
#     disk   = number
#     bridge = string
#   })
# }

variable "kvm" {
  type    = string
  default = "qemu://system"
}
