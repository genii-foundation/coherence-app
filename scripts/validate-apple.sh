#!/bin/sh
set -eu

root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
project="$root/apps/apple/Coherence.xcodeproj"
work="$root/.build/apple-validation"
derived="$work/DerivedData"
results="$work/Results"
phone_id=
watch_id=

cleanup() {
    if [ -n "$watch_id" ]; then
        xcrun simctl delete "$watch_id" >/dev/null 2>&1 || true
    fi
    if [ -n "$phone_id" ]; then
        xcrun simctl delete "$phone_id" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT INT TERM

if [ ! -d "$project" ]; then
    printf 'Missing %s. Run scripts/generate-apple-project.sh first.\n' "$project" >&2
    exit 1
fi

if ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
    printf 'Xcode license acceptance or first launch setup is incomplete.\n' >&2
    exit 1
fi

actual_xcode_version=$(xcodebuild -version | awk 'NR == 1 {print $2}')
if [ -n "${COHERENCE_EXPECTED_XCODE_VERSION:-}" ] && [ "$actual_xcode_version" != "$COHERENCE_EXPECTED_XCODE_VERSION" ]; then
    printf 'Expected Xcode %s, found %s.\n' "$COHERENCE_EXPECTED_XCODE_VERSION" "$actual_xcode_version" >&2
    exit 1
fi

ios_runtime=$(xcrun simctl list runtimes --json | jq -r '[.runtimes[] | select(.isAvailable and (.identifier | contains("SimRuntime.iOS-")))] | last | .identifier // empty')
watch_runtime=$(xcrun simctl list runtimes --json | jq -r '[.runtimes[] | select(.isAvailable and (.identifier | contains("SimRuntime.watchOS-")))] | last | .identifier // empty')

if [ -z "$ios_runtime" ]; then
    printf 'No available iOS simulator runtime. Run: xcodebuild -downloadPlatform iOS\n' >&2
    exit 1
fi
if [ -z "$watch_runtime" ]; then
    printf 'No available watchOS simulator runtime. Run: xcodebuild -downloadPlatform watchOS\n' >&2
    exit 1
fi

rm -rf "$work"
mkdir -p "$derived" "$results"

phone_type=com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro
watch_type=com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-11-46mm
suffix="$$"

printf 'Creating and booting a temporary paired iPhone and Watch simulator set.\n'
phone_id=$(xcrun simctl create "Coherence Phase 0B iPhone $suffix" "$phone_type" "$ios_runtime")
watch_id=$(xcrun simctl create "Coherence Phase 0B Watch $suffix" "$watch_type" "$watch_runtime")
xcrun simctl pair "$watch_id" "$phone_id" >/dev/null
xcrun simctl boot "$phone_id"
xcrun simctl boot "$watch_id"
xcrun simctl bootstatus "$phone_id" -b >/dev/null
xcrun simctl bootstatus "$watch_id" -b >/dev/null

printf 'Building the iPhone and embedded Watch applications with Xcode %s.\n' "$actual_xcode_version"
xcodebuild \
    -quiet \
    -project "$project" \
    -scheme Coherence \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$derived" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    build

printf 'Building the Watch application independently.\n'
xcodebuild \
    -quiet \
    -project "$project" \
    -scheme CoherenceWatch \
    -destination 'generic/platform=watchOS Simulator' \
    -derivedDataPath "$derived" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    build

phone_app="$derived/Build/Products/Debug-iphonesimulator/Coherence.app"
embedded_watch_app="$phone_app/Watch/CoherenceWatchApp.app"

test -d "$phone_app"
test -d "$embedded_watch_app"
test "$(plutil -extract CFBundleIdentifier raw "$phone_app/Info.plist")" = 'org.providencecollective.coherence'
test "$(plutil -extract CFBundleIdentifier raw "$embedded_watch_app/Info.plist")" = 'org.providencecollective.coherence.watchkitapp'
test "$(plutil -extract WKCompanionAppBundleIdentifier raw "$embedded_watch_app/Info.plist")" = 'org.providencecollective.coherence'

printf 'Running iPhone unit and interface smoke tests.\n'
xcodebuild \
    -quiet \
    -project "$project" \
    -scheme Coherence \
    -destination "id=$phone_id" \
    -derivedDataPath "$derived" \
    -resultBundlePath "$results/Coherence.xcresult" \
    test

printf 'Running Watch composition tests.\n'
xcodebuild \
    -quiet \
    -project "$project" \
    -scheme CoherenceWatch \
    -destination "id=$watch_id" \
    -derivedDataPath "$derived" \
    -resultBundlePath "$results/CoherenceWatch.xcresult" \
    test

printf 'Apple application builds, embedding checks, and simulator tests passed.\n'
