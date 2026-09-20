#!/bin/bash
set -e

echo "=== Starting Flutter Web Build for Vercel ==="

FLUTTER_VERSION="3.29.0"
FLUTTER_DIR="./flutter"

if [ -d "$FLUTTER_DIR" ]; then
  echo "Flutter directory exists. Updating..."
  cd "$FLUTTER_DIR"
  git fetch --tags
  git checkout "tags/$FLUTTER_VERSION"
  cd ..
else
  echo "Cloning Flutter SDK ($FLUTTER_VERSION)..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Flutter Environment ==="
flutter --version

echo "=== Fetching Flutter Packages ==="
flutter pub get

echo "=== Building Production Web Bundle ==="
flutter build web --release --base-href "/"

echo "=== Build Complete! Artifacts in build/web ==="
