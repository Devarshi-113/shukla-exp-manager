#!/bin/bash

# Clone the Flutter repository
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to the path
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web support
flutter config --enable-web

# Build the project
flutter build web --release --base-href "/"