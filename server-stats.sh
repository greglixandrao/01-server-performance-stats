#!/bin/bash

# Colors for output styling
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

# Title with date and time
echo -e "${CYAN}Server Performance Stats Report${RESET}"
echo -e "${GREEN}Generated on: $(date)${RESET}"
echo "=============================================="

# OS Version
echo -e "${YELLOW}\n🔹 OS Version:${RESET}"
cat /etc/os-release | grep -e "^NAME=" -e "^VERSION=" | sed 's/NAME=//;s/VERSION=//' | xargs -I {} echo -e "  - {}"

# Uptime
echo -e "${YELLOW}\n🔹 Uptime:${RESET}"
echo -e "  $(uptime -p)"

# Load Average
echo -e "${YELLOW}\n🔹 Load Average (1, 5, 15 minutes):${RESET}"
echo -e "  $(uptime | awk -F'load average:' '{ print $2 }' | xargs)"

# Logged-in Users
echo -e "${YELLOW}\n🔹 Logged-in Users:${RESET}"
who | awk '{print $1}' | sort | uniq -c | sort -nr | awk '{printf "  - %s: %s users\n", $2, $1}'

# Failed Login Attempts
echo -e "${YELLOW}\n🔹 Failed Login Attempts:${RESET}"
failed_attempts=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
echo -e "  - Total: ${failed_attempts}"

# CPU Usage
echo -e "${CYAN}\n💻 CPU Usage:${RESET}"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | \
sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
awk '{print 100 - $1"%"}')
echo -e "  - Total CPU Usage: ${cpu_usage}"

# Memory Usage
echo -e "${CYAN}\n🧠 Memory Usage (Free vs Used):${RESET}"
free -m | awk 'NR==2{printf "  - Used: %s MB (%.2f%%)\n  - Free: %s MB (%.2f%%)\n", $3, $3*100/$2, $4, $4*100/$2 }'

# Disk Usage
echo -e "${CYAN}\n💾 Disk Usage (Free vs Used):${RESET}"
df -h --total | grep "total" | awk '{printf "  - Used: %s (%s)\n  - Free: %s\n", $3, $5, $4}'

# Top 5 Processes by CPU Usage
echo -e "${RED}\n🔥 Top 5 Processes by CPU Usage:${RESET}"
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6 | awk '{printf "  - PID: %s | CMD: %-15s | CPU: %s%%\n", $1, $3, $4}'

# Top 5 Processes by Memory Usage
echo -e "${RED}\n🔥 Top 5 Processes by Memory Usage:${RESET}"
ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6 | awk '{printf "  - PID: %s | CMD: %-15s | MEM: %s%%\n", $1, $3, $4}'

echo -e "${GREEN}\n=============================================="
echo -e "End of Report${RESET}"
