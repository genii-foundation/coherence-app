#!/bin/sh
set -eu

root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)

cd "$root/packages/CoherenceKit"
DEVELOPER_DIR=/Library/Developer/CommandLineTools swift build --build-system native
DEVELOPER_DIR=/Library/Developer/CommandLineTools swift run --build-system native CoherenceCoreVerification

cd "$root"

if find apps -name '*.xcodeproj' -print -quit | grep -q .; then
    if ! xcodebuild -version >/dev/null 2>&1; then
        printf 'The Xcode project exists, but Xcode activation is incomplete.\n' >&2
        exit 1
    fi
else
    printf 'Shared package validated. Apple target validation begins after native project bootstrap.\n'
fi
