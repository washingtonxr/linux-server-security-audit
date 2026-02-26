#!/bin/bash

# Define colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Ubuntu Server Security Report ===${NC}"
echo "Generated on: $(date)"
echo "--------------------------------------"

echo -e "\n${GREEN}1. SSH Configuration Check${NC}"
# Checking for best practice settings
grep -E "^(PermitRootLogin|PasswordAuthentication|Port|PubkeyAuthentication|MaxAuthTries)" /etc/ssh/sshd_config || echo "No custom SSH settings found."

echo -e "\n${GREEN}2. Network: Listening Ports${NC}"
# Shows processes tied to ports
ss -tulpn | grep LISTEN

echo -e "\n${GREEN}3. Brute Force Check (Latest Failed Logins)${NC}"
# Checks both auth.log (standard) and journalctl as a backup
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || journalctl _SYSTEMD_UNIT=ssh.service | grep "Failed" | tail -5

echo -e "\n${GREEN}4. User & Privilege Audit${NC}"
echo "Current Sessions:"
who
echo -e "\nAccounts with UID 0 (Root Privileges):"
awk -F: '($3 == "0") {print $1}' /etc/passwd

echo -e "\n${GREEN}5. System Resource Integrity${NC}"
echo "Disk Usage:"
df -h -x tmpfs -x devtmpfs
echo -e "\nMemory Usage:"
free -h

echo -e "\n${GREEN}6. Software Vulnerability Check${NC}"
UPDATES=$(apt list --upgradable 2>/dev/null | wc -l)
echo "Pending Updates: $((UPDATES - 1))"
if [ "$UPDATES" -gt 1 ]; then
    apt list --upgradable 2>/dev/null | head -n 5
fi

echo -e "\n${GREEN}7. Firewall & Fail2Ban Status${NC}"
if command -v ufw >/dev/null; then
    ufw status | grep -q "active" && echo "UFW: Active" || echo "UFW: Inactive"
fi
fail2ban-client status 2>/dev/null || echo "Fail2ban: Not installed"

echo -e "\n${GREEN}8. Critical File Permissions${NC}"
echo "Checking for world-writable files in /home (Potential risk):"
find /home -maxdepth 2 -type f -perm -o+w 2>/dev/null || echo "None found."

echo -e "\n${GREEN}=== Audit Complete ===${NC}"
