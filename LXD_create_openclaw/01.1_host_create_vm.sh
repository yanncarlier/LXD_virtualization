#!/bin/bash
# =============================================================================
# 01_host_create_vm.sh
# Run this on your UBUNTU HOST (not inside the VM)
# Step 1 of 2: Creates and launches the LXD VM, then stops it cleanly
#              so that 01.2_host_create_vm.sh can apply boot-time config.
# =============================================================================

set -euo pipefail

VM_NAME="openclaw"
IMAGE="ubuntu:25.10"
CPUS=2
RAM="4GB"
DISK="10GB"

echo "============================================="
echo " OpenClaw LXD VM Setup — Step 1/2"
echo "============================================="

# ── 1. Ensure LXD is initialised ──────────────────────────────────────────────
if ! lxc info &>/dev/null; then
  echo "[!] LXD not initialised. Running lxd init --auto..."
  sudo lxd init --auto
fi

# ── 2. Launch the VM ──────────────────────────────────────────────────────────
echo "[*] Launching VM '${VM_NAME}' from ${IMAGE}..."
lxc launch "${IMAGE}" "${VM_NAME}" \
  --vm \
  --config limits.cpu="${CPUS}" \
  --config limits.memory="${RAM}" \
  --device root,size="${DISK}"

echo "[*] Waiting for VM to boot (30s)..."
sleep 30


# ── 3. Stop VM cleanly so step 2 can apply boot-time config ───────────────────
echo "[*] Stopping VM cleanly for config phase..."
lxc stop "${VM_NAME}"

echo ""
echo "============================================="
echo " Step 1 complete. VM is stopped and ready."
echo " Run next:  bash 01.2_host_config_and_start.sh"
echo "============================================="
echo ""