provider "libvirt" {
    # uri = "qemu://system"
    # uri = "qemu+ssh://sergey@serhiopc/system"
    uri = "qemu+ssh://sergey@serhiopc/system?keyfile=/home/sergey/.ssh/id_laptop_wsl&sshauth=privkey"
}