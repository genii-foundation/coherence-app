#!/bin/sh
set -eu

root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)

if [ -d "$root/apps/coherence-mobile" ]; then
    printf 'Application implementations must be grouped by platform under apps, not under apps/coherence-mobile.\n' >&2
    exit 1
fi

core="$root/packages/swift/CoherenceKit/Sources/CoherenceCore"
if grep -ERn 'HealthKit|WatchConnectivity|Apple Watch|Health Connect|Wear OS' "$core"; then
    printf 'Vendor API names must remain outside CoherenceCore.\n' >&2
    exit 1
fi

cd "$root/packages/swift/CoherenceKit"
DEVELOPER_DIR=/Library/Developer/CommandLineTools swift build --build-system native
swift test --build-system native
DEVELOPER_DIR=/Library/Developer/CommandLineTools swift run --build-system native CoherenceCoreVerification

cd "$root"

if find apps -name '*.xcodeproj' -print -quit | grep -q .; then
    "$root/scripts/validate-apple.sh"
else
    printf 'Shared package validated. Apple target validation begins after native project bootstrap.\n'
fi
