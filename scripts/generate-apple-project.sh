#!/bin/sh
set -eu

root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
required_version=2.45.4

if ! command -v xcodegen >/dev/null 2>&1; then
    printf 'XcodeGen %s is required. Install it with: brew install xcodegen\n' "$required_version" >&2
    exit 1
fi

actual_version=$(xcodegen --version | awk '{print $2}')
if [ "$actual_version" != "$required_version" ]; then
    printf 'Expected XcodeGen %s, found %s.\n' "$required_version" "$actual_version" >&2
    exit 1
fi

xcodegen generate --spec "$root/apps/apple/project.yml" --quiet
printf 'Generated apps/apple/Coherence.xcodeproj with XcodeGen %s.\n' "$actual_version"
