#!/bin/bash
SRC="$1"
DST="$2"
mkdir -p "$DST"
sips -z 16 16 "$SRC" --out "$DST/Icon-16.png" 2>/dev/null
sips -z 32 32 "$SRC" --out "$DST/Icon-16@2x.png" 2>/dev/null
sips -z 32 32 "$SRC" --out "$DST/Icon-32.png" 2>/dev/null
sips -z 64 64 "$SRC" --out "$DST/Icon-32@2x.png" 2>/dev/null
sips -z 128 128 "$SRC" --out "$DST/Icon-128.png" 2>/dev/null
sips -z 256 256 "$SRC" --out "$DST/Icon-128@2x.png" 2>/dev/null
sips -z 256 256 "$SRC" --out "$DST/Icon-256.png" 2>/dev/null
sips -z 512 512 "$SRC" --out "$DST/Icon-256@2x.png" 2>/dev/null
sips -z 512 512 "$SRC" --out "$DST/Icon-512.png" 2>/dev/null
sips -z 1024 1024 "$SRC" --out "$DST/Icon-512@2x.png" 2>/dev/null
echo "Fatto!"
