#!/usr/bin/env bash
set -euo pipefail

VM_NAME="arch-hyprland"
RAM_MB="4096"
CPUS="4"
DISK_GB="32"
DISK_PATH="$HOME/VMs/$VM_NAME.qcow2"
ISO_PATH="$HOME/Downloads/archlinux-2026.08.01-x86_64.iso"

color() { tput setaf "$1"; tput bold; }
reset() { tput sgr0; }
info()  { echo "$(color 2)::$(reset) $*"; }
warn()  { echo "$(color 3)!!$(reset) $*"; }

mkdir -p "$HOME/VMs" "$HOME/Downloads"

if [ ! -f "$ISO_PATH" ]; then
    info "downloading latest Arch ISO..."
    curl -Lo "$ISO_PATH" "$(curl -s https://archlinux.org/releng/releases/json/latest | grep -oP '"iso_url":\s*"\K[^"]+')"
fi

if [ -f "$DISK_PATH" ]; then
    warn "disk already exists at $DISK_PATH — delete it first or use a different name"
    exit 1
fi

info "creating disk ($DISK_GB GB)..."
qemu-img create -f qcow2 "$DISK_PATH" "${DISK_GB}G" >/dev/null

info "launching VM..."
virt-install \
    --name "$VM_NAME" \
    --ram "$RAM_MB" \
    --vcpus "$CPUS" \
    --disk "$DISK_PATH",bus=virtio \
    --cdrom "$ISO_PATH" \
    --os-variant archlinux \
    --boot uefi \
    --network network=default,model=virtio \
    --graphics spice \
    --video virtio \
    --sound ich9 \
    --channel spicevmc \
    --channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
    --virt-type kvm \
    --cpu host \
    --noautoconsole

info "VM '$VM_NAME' created. Connect with: virt-viewer $VM_NAME"
info "or open virt-manager and double-click it."
