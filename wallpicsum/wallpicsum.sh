#!/bin/bash
# wallpicsum - Blame Microsoft™

# Default resolution
width=3500
height=5000

# Parse flags
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --width) width="$2"; shift 2 ;;
    --height) height="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# URL and filename
url="https://picsum.photos/${width}/${height}"
filename="wallpicsum_${width}x${height}_$(date +%s).jpg"
tmpfile=$(mktemp)

# Target dirs
targets=("/usr/share/wallpapers" "/usr/share/backgrounds")

# Download
curl -sL "$url" -o "$tmpfile" || exit 1

# Determine invoking user
invoker=$(logname 2>/dev/null || echo $SUDO_USER)

# Install to system dirs with correct ownership
for dir in "${targets[@]}"; do
  sudo mkdir -p "$dir"
  sudo cp -f "$tmpfile" "$dir/$filename"
  sudo chown "$invoker":"$invoker" "$dir/$filename"
done

echo "Downloaded $filename to:"
for dir in "${targets[@]}"; do
  echo "  → $dir"
done

rm -f "$tmpfile"
