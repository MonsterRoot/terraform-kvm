provider "libvirt" {
    # uri = "qemu://system"
    # uri = "qemu+ssh://sergey@serhiopc/system"
    uri = "${var.kvm}"
}