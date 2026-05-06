#!/bin/bash
# =======================================================================
# RHEL 7.9 Template Cleanup Script
# - Cleans network identity (DHCP ready)
# - Resets machine identity
# - Removes SSH keys
# - Cleans logs, temp files, history
# - Prepares VM for Proxmox template conversion
# =======================================================================

set -e

echo "[INFO] Starting template cleanup..."

# ---------- Step 1: Clean network persistent rules ----------
echo "[INFO] Cleaning network rules..."
rm -f /etc/udev/rules.d/70-persistent-net.rules

# ---------- Step 2: Clean DHCP leases ----------
echo "[INFO] Removing DHCP leases..."
rm -rf /var/lib/dhclient/*
rm -rf /var/lib/NetworkManager/*

# ---------- Step 3: Fix network config ----------
echo "[INFO] Ensuring DHCP configuration..."

for cfg in /etc/sysconfig/network-scripts/ifcfg-*; do
    [ -f "$cfg" ] || continue

    sed -i '/^HWADDR=/d' "$cfg"
    sed -i '/^UUID=/d' "$cfg"

    grep -q "^BOOTPROTO=" "$cfg" && \
        sed -i 's/^BOOTPROTO=.*/BOOTPROTO=dhcp/' "$cfg" || \
        echo "BOOTPROTO=dhcp" >> "$cfg"

    grep -q "^ONBOOT=" "$cfg" || echo "ONBOOT=yes" >> "$cfg"
done

# ---------- Step 4: Reset machine-id ----------
echo "[INFO] Resetting machine-id..."
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# ---------- Step 5: Reset hostname ----------
echo "[INFO] Resetting hostname..."
echo "localhost.localdomain" > /etc/hostname
hostnamectl set-hostname localhost.localdomain

# ---------- Step 6: Remove SSH host keys ----------
echo "[INFO] Removing SSH host keys..."
rm -f /etc/ssh/ssh_host_*

# ---------- Step 7: Clean logs ----------
echo "[INFO] Cleaning logs..."
# rm -rf /var/log/*
rm -f /var/log/*
mkdir -p /var/log/{audit,sa}
touch /var/log/messages /var/log/secure /var/log/audit/audit.log

# ---------- Step 8: Clean temp files ----------
echo "[INFO] Cleaning temp files..."
rm -rf /tmp/*
rm -rf /var/tmp/*

# ---------- Step 9: Clear shell history ----------
echo "[INFO] Clearing shell history..."
history -c
cat /dev/null > ~/.bash_history

# ---------- Step 10: Sync disk ----------
sync

echo "[SUCCESS] Cleanup complete. Shutdown VM and convert to template."
