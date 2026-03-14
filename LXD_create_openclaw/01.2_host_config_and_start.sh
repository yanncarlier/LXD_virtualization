#!/bin/bash
# =============================================================================
# 01.2_host_config_and_start.sh
# Run this on your UBUNTU HOST (not inside the VM)
# Step 2 of 2: Applies boot-time config, starts the VM, pushes setup script.
#
# SPICE note: LXD automatically creates a SPICE unix socket — do NOT add
# a -spice flag via raw.qemu or QEMU will fail with a duplicate -spice error.
# Connect with:
#   lxc console openclaw --type=vga
#   remote-viewer spice+unix:///var/snap/lxd/common/lxd/logs/openclaw/qemu.spice
# =============================================================================

set -euo pipefail

VM_NAME="openclaw"

echo "============================================="
echo " OpenClaw LXD VM Setup — Step 2/2"
echo "============================================="

# ── 1. Confirm VM exists and is stopped ───────────────────────────────────────
STATUS=$(lxc list "${VM_NAME}" --format csv --columns s 2>/dev/null | head -1)
if [[ -z "${STATUS}" ]]; then
  echo "[!] VM '${VM_NAME}' not found. Run 01_host_create_vm.sh first."
  exit 1
fi
if [[ "${STATUS}" != "STOPPED" ]]; then
  echo "[!] VM '${VM_NAME}' is not stopped (status: ${STATUS})."
  echo "    Run: lxc stop ${VM_NAME}"
  exit 1
fi

# ── 2. Apply boot-time config ─────────────────────────────────────────────────
# NOTE: Do NOT inject -spice via raw.qemu.
#       LXD already adds its own SPICE unix socket in qemu.conf automatically.
#       Adding a second -spice flag causes QEMU to exit with status 1.
echo "[*] Applying boot-time VM config..."
lxc config set "${VM_NAME}" boot.autostart true
lxc config set "${VM_NAME}" boot.autostart.delay 5

# ── 3. Start VM ───────────────────────────────────────────────────────────────
echo "[*] Starting VM..."
lxc start "${VM_NAME}"
echo "[*] Waiting for VM to boot (30s)..."
sleep 30

# ── 4. Push in-VM setup script ────────────────────────────────────────────────
echo "[*] Pushing in-VM setup script..."
lxc file push 02.0_vm_setup.sh "${VM_NAME}/root/02.0_vm_setup.sh"
lxc file push 02.1_vm_setup.sh "${VM_NAME}/root/02.1_vm_setup.sh"
lxc file push 03.0_openclaw_configure.sh "${VM_NAME}/root/03.0_openclaw_configure.sh"

lxc exec "${VM_NAME}" -- chmod +x /root/02.0_vm_setup.sh
lxc exec "${VM_NAME}" -- chmod +x /root/02.1_vm_setup.sh
lxc exec "${VM_NAME}" -- chmod +x /root/03.0_openclaw_configure.sh

# ── 5. Print connection info ──────────────────────────────────────────────────
SPICE_SOCK="/var/snap/lxd/common/lxd/logs/${VM_NAME}/qemu.spice"

echo ""
echo "============================================="
echo " VM is running. Connect via:"
echo "============================================="
echo ""
echo "  VGA console (simplest):"
echo "    lxc console ${VM_NAME} --type=vga"
echo ""
echo "  SPICE unix socket:"
echo "    remote-viewer spice+unix://${SPICE_SOCK}"
echo "    (install: sudo apt install virt-viewer)"
echo ""
echo "  Shell:"
echo "    lxc exec ${VM_NAME} -- bash"
echo ""
echo "  Then inside the VM:"
echo "    bash /root/02.0_vm_setup.sh"
echo ""