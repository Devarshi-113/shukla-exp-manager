#!/bin/bash

# 1. Exit on any error
set -e

# 2. Add Flutter to the PATH
echo "Cloning Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Ensure we are in the right place and dependencies are met
echo "Running pub get..."
flutter pub get

# 4. Build the project
echo "Starting Build..."
flutter build web --release --base-href "/"

# 5. List files to verify build success (helps with debugging)
ls -R build/web
# changed to LF for linux