

#!/bin/bash
# =============================================================================
# 
# 
# ── 4. UFW — allow LXD bridge traffic (required for VM DHCP + internet) ───────
# 
# =============================================================================

set -euo pipefail

echo "[*] Configuring UFW bridge rules..."
ufw allow in on lxdbr0        2>/dev/null || true
ufw route allow in on lxdbr0  2>/dev/null || true
ufw route allow out on lxdbr0 2>/dev/null || true
lxc network set lxdbr0 ipv4.nat true