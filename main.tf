resource "libvirt_pool" "pool" {
  name = "${var.prefix}pool"
  type = "dir"
  path = "${var.pool_path}${var.prefix}pool"
}

resource "libvirt_network" "bridge" {
  name = "bridge"
  mode = "bridge"
  bridge = "br0"
}

resource "libvirt_network" "default" {
  name = "default"
  mode = "nat"

  addresses = ["192.168.122.0/24"]

  # (Optional) DNS configuration
  dns {
    enabled = true
    local_only = true

    # (Optional) one or more DNS forwarder entries.  One or both of
    # "address" and "domain" must be specified.  The format is:
    # forwarders {
    #     address = "my address"
    #     domain = "my domain"
    #  } 
    # 

    # (Optional) one or more DNS host entries.  Both of
    # "ip" and "hostname" must be specified.  The format is:
    # hosts  {
    #     hostname = "my_hostname"
    #     ip = "my.ip.address.1"
    #   }
    # hosts {
    #     hostname = "my_hostname"
    #     ip = "my.ip.address.2"
    #   }
    # 

    # (Optional) one or more static routes.
    # "cidr" and "gateway" must be specified. The format is:
    # routes {
    #     cidr = "10.17.0.0/16"
    #     gateway = "10.18.0.2"
    #   }
  }
}

resource "libvirt_volume" "image" {
  name   = var.image.name
  format = "qcow2"
  pool   = libvirt_pool.pool.name
  source = var.image.url
}

resource "libvirt_volume" "root" {
  count = length(var.domains)

  name           = "${var.prefix}${var.domains[count.index].name}-root"
  pool           = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.image.id
  size           = var.domains[count.index].disk
}

resource "libvirt_domain" "vm" {
  count = length(var.domains)

  name   = "${var.prefix}${var.domains[count.index].name}"
  vcpu   = var.domains[count.index].cpu
  memory = var.domains[count.index].ram

  qemu_agent = true
  autostart  = true

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_id     = libvirt_network.bridge.id
    wait_for_lease = true
  }
  disk {
    volume_id = libvirt_volume.root[count.index].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  pool           = libvirt_pool.pool.name
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}