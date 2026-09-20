#!/bin/bash
set -e

echo "=== Starting Flutter Web Build for Vercel ==="

# Prevent Git 128 "fatal: detected dubious ownership in repository" in CI/Docker
git config --global --add safe.directory "*" 2>/dev/null || true

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.1}"
FLUTTER_DIR="$(pwd)/flutter"

# Check if working flutter binary already exists and matches expected version
if [ -x "$FLUTTER_DIR/bin/flutter" ] && [ -f "$FLUTTER_DIR/version" ] && [ "$(cat "$FLUTTER_DIR/version" | tr -d '\r\n')" = "$FLUTTER_VERSION" ]; then
  echo "=== Existing Flutter SDK ($FLUTTER_VERSION) found in cache ==="
else
  echo "=== Installing Flutter SDK ($FLUTTER_VERSION) ==="
  rm -rf "$FLUTTER_DIR" flutter.tar.xz

  # Method 1: Fast direct download of official pre-built Linux tarball from Google Cloud Storage
  echo "Downloading pre-built Flutter Linux package..."
  if curl -sSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o flutter.tar.xz; then
    echo "Extracting Flutter SDK archive..."
    tar -xf flutter.tar.xz
    rm -f flutter.tar.xz
  else
    echo "Download failed; falling back to shallow git clone of stable branch..."
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  fi
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Ensure git safe directory for the extracted/cloned Flutter SDK
git config --global --add safe.directory "$FLUTTER_DIR" 2>/dev/null || true

echo "=== Flutter Environment ==="
flutter --version

echo "=== Configuring Flutter Web ==="
flutter config --no-analytics
flutter config --enable-web

echo "=== Fetching Flutter Packages ==="
flutter pub get

echo "=== Building Production Web Bundle ==="
flutter build web --release --base-href "/"

echo "=== Build Complete! Output located in build/web ==="
