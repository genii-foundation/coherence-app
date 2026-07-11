#!/bin/sh
set -eu

printf 'Swift: '
DEVELOPER_DIR=/Library/Developer/CommandLineTools swiftc -version | head -n 1

printf 'Developer directory: '
xcode-select -p

if [ -d /Applications/Xcode.app ]; then
    printf 'Full Xcode: installed\n'
    xcodebuild -version
    if xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
        printf 'Xcode activation: complete\n'
    else
        printf 'Xcode activation: license or first launch setup pending\n'
    fi
else
    printf 'Full Xcode: missing\n'
    printf 'Install Xcode with iOS and watchOS platforms before creating the Apple project.\n'
fi
