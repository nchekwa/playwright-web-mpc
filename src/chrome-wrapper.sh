#!/bin/bash

# Search for the actual Chrome executable path
REAL_CHROME=$(ls /ms-playwright/chromium-*/chrome-linux/chrome)

if [ -z "$REAL_CHROME" ]; then
    echo "Error: Real Chrome executable not found!" >&2
    exit 1
fi

# Aggregate browser-specific options here
exec "$REAL_CHROME" \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --user-data-dir=/tmp/shared-browser-data \
  --disable-features=Vulkan \
  --use-gl=swiftshader \
  --ignore-https-errors \
  "$@"
