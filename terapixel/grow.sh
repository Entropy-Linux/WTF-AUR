#!/bin/bash
IMGDIR="/usr/share/terapixel-image"
vips resize "$IMGDIR/10k.png" "$IMGDIR/1M.png" 100
