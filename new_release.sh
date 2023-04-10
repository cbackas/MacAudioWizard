# /bin/bash

# This script is used to create a new release of the project.
swift build -c release
cp -f .build/release/macaudiowizard /Users/zac/Programs/macaudiowizard
