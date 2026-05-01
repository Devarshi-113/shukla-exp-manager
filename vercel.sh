#!/bin/bash

# 1. Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# 2. Run Doctor to ensure environment is ready
flutter doctor

# 3. Enable Web and Build
flutter config --enable-web
flutter build web --release --base-href "/"

# 4. Check if build was successful
if [ -d "build/web" ]; then
  echo "Build successful."
else
  echo "Build failed."
  exit 1
fi