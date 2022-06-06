variable "os_version" {
  default = "snapshots"
  type = string
  description = "The version of OpenBSD to build"
}

variable "os_number" {
  type = string
  description = "The numbered extension while building snapshots"
}

variable "machine_type" {
  default = "pc"
  type = string
  description = "The type of machine to use when building"
}

variable "cpu_type" {
  default = "qemu64"
  type = string
  description = "The type of CPU to use when building"
}

variable "memory" {
  default = 4096
  type = number
  description = "The amount of memory to use when building the VM in megabytes"
}

variable "cpus" {
  default = 2
  type = number
  description = "The number of cpus to use when building the VM"
}

variable "disk_size" {
  default = "50G"
  type = string
  description = "The size in bytes of the hard disk of the VM"
}

variable "checksum" {
  type = string
  description = "The checksum for the virtual hard drive file"
}

variable "root_password" {
  default = "packer"
  type = string
  description = "The password for the root user"
}

variable "headless" {
  default = true
  description = "When this value is set to `true`, the machine will start without a console"
}

variable "firmware" {
  default = "OVMF.fd"
  type = string
  description = "The firmware file to be used by QEMU"
}

variable "readonly_boot_media" {
  default = false
  description = "If true, the boot media will be mounted as readonly"
}

variable "vnc_bind_address" {
  default = "127.0.0.1"
  description = "VNC server bind address"
}

locals {
  image_architecture = "amd64"

  image = "miniroot${var.os_number}.img"
  vm_name = "openbsd-${var.os_version}-x86_64.qcow2"

  iso_target_extension = "img"
  iso_target_path = "packer_cache"
  iso_full_target_path = "${local.iso_target_path}/${var.checksum}.${local.iso_target_extension}"

  readonly_boot_media = var.readonly_boot_media ? "on" : "off"
}

source "qemu" "qemu" {
  boot_command = [
    "a<enter>",
    "<wait5>",
    "http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter>",
    "<wait15>",
    "i<enter>",
  ]
  boot_wait = "30s"

  cpus = var.cpus

  disk_compression = true
  disk_size = var.disk_size

  firmware = var.firmware

  headless = var.headless

  machine_type = var.machine_type
  memory = var.memory

  ssh_username = "root"
  ssh_password = var.root_password
  ssh_timeout = "10000s"

  vnc_bind_address = var.vnc_bind_address

  qemuargs = [
    ["-boot", "strict=off"],
    ["-monitor", "none"],
    ["-device", "virtio-scsi-pci"],
    ["-device", "scsi-hd,drive=drive0,bootindex=0"],
    ["-device", "scsi-hd,drive=drive1,bootindex=1"],
    ["-drive", "if=none,file={{ .OutputDir }}/{{ .Name }},id=drive0,cache=writeback,discard=ignore,format=qcow2"],
    ["-drive", "if=none,file=${local.iso_full_target_path},id=drive1,media=disk,format=raw,readonly=${local.readonly_boot_media}"],
  ]

  iso_checksum = var.checksum
  iso_target_extension = local.iso_target_extension
  iso_target_path = local.iso_full_target_path
  iso_url = "http://cdn.openbsd.org/pub/OpenBSD/${var.os_version}/${local.image_architecture}/${local.image}"

  http_directory = "."
  output_directory = "output"
  shutdown_command = "shutdown -h -p now"
  vm_name = local.vm_name
}

build {
  sources = ["qemu.qemu"]

  provisioner "shell" {
    script = "provision.sh"
  }
}
