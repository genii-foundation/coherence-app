#!/bin/sh
set -eu

printf 'Swift: '
DEVELOPER_DIR=/Library/Developer/CommandLineTools swiftc -version | head -n 1

printf 'Developer directory: '
printf '%s\n' "${DEVELOPER_DIR:-$(xcode-select -p)}"

if xcodebuild -version 2>/dev/null | grep -q '^Xcode '; then
    printf 'Full Xcode: installed\n'
    xcodebuild -version
    if xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
        printf 'Xcode activation: complete\n'
    else
        printf 'Xcode activation: license or first launch setup pending\n'
    fi

    printf 'iOS SDK: '
    xcrun --sdk iphoneos --show-sdk-version 2>/dev/null || printf 'missing\n'
    printf 'watchOS SDK: '
    xcrun --sdk watchos --show-sdk-version 2>/dev/null || printf 'missing\n'

    if xcrun simctl list runtimes --json >/dev/null 2>&1; then
        printf 'Available simulator runtimes:\n'
        xcrun simctl list runtimes --json \
            | jq -r '.runtimes[] | select(.isAvailable) | "  \(.name)"'
    else
        printf 'Available simulator runtimes: unavailable\n'
    fi

    macos_major=$(sw_vers -productVersion | cut -d. -f1)
    xcode_major=$(xcodebuild -version | awk 'NR == 1 {split($2, value, "."); print value[1]}')
    if [ "$macos_major" -ge 26 ] && [ "$xcode_major" -ge 26 ] && [ "$macos_major" -gt "$xcode_major" ]; then
        printf 'Compatibility warning: Xcode %s is not an officially supported GUI toolchain on macOS %s.\n' "$xcode_major" "$macos_major"
    fi
else
    printf 'Full Xcode: missing\n'
    printf 'Install Xcode with iOS and watchOS platforms before creating the Apple project.\n'
fi
