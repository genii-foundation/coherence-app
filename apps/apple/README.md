# Apple applications

This directory owns Coherence implementations for Apple platforms. It is not a product named Coherence Mobile. The first targets are iPhone under `ios` and Apple Watch under `watchos`. Future iPad, macOS, tvOS, or visionOS targets belong here when they have a real executable or capability spike.

The application targets remain intentionally thin. Reusable Swift implementation logic belongs in `packages/swift/CoherenceKit`. Platform neutral interchange contracts and conformance fixtures belong in `packages/contracts`.

## Project source of truth

`project.yml` is the versioned source of truth for `Coherence.xcodeproj`. The generated project is also committed so Xcode can open a clean checkout without a generation step. Regenerate it only with XcodeGen 2.45.4:

```sh
./scripts/generate-apple-project.sh
git diff apps/apple/Coherence.xcodeproj
```

Review any generated diff before committing it. Do not make durable target or scheme changes only inside the generated project because the next generation will quite reasonably eat them.

## Targets and schemes

The target graph is:

1. `CoherenceApp` is the iOS application. Its bundle identifier is `org.providencecollective.coherence`.
2. `CoherenceWatchApp` is the embedded watchOS companion. Its bundle identifier is `org.providencecollective.coherence.watchkitapp`.
3. `CoherenceAppTests` contains iOS unit tests.
4. `CoherenceAppUITests` contains iOS interface tests.
5. `CoherenceWatchAppTests` contains watchOS unit tests.

The shared schemes are `Coherence` for the phone application and embedded companion, and `CoherenceWatch` for the Watch application independently.

The project links the local package at `../../packages/swift/CoherenceKit`. `CoherenceApp` links `CoherenceCore`, `CoherenceAcquisition`, `CoherenceData`, `CoherenceSync`, and `CoherenceFeatures`. `CoherenceWatchApp` links `CoherenceCore`, `CoherenceAcquisition`, `CoherenceData`, and `CoherenceSync`. Adding vendor specific behavior to those core modules remains forbidden, even if Xcode offers to make the mistake attractively.

## Build and test

Run all repository and Apple validation with:

```sh
./scripts/doctor.sh
./scripts/validate.sh
```

Apple validation creates a temporary paired iPhone and Watch simulator set, builds the phone application and embedded Watch application, verifies companion bundle identifiers, builds the Watch application independently, and runs the three native test targets. Signing is disabled because Phase 0B is a simulator bootstrap.

For a focused Apple run:

```sh
./scripts/validate-apple.sh
```

Open `Coherence.xcodeproj` in a supported Xcode installation for interactive work. On the current macOS 27 beta host, the installed Xcode 26.6 command line tools build successfully, but the Xcode 26.6 graphical application is not a supported pairing. Xcode 27 beta still requires an authenticated Apple download before it can be used for graphical development on that host.

## Synthetic sensor mode

Both shared schemes pass this Debug launch argument:

```text
COHERENCE_USE_FAKE_SENSORS=1
```

The argument selects a deterministic in memory sensor adapter and produces an unmistakably synthetic heart rate batch. Release builds ignore fake sensor selection. This is test composition, not a back door into HealthKit, which would be both architecturally wrong and impressively cursed.

## Phase boundaries

Use iOS 18 and watchOS 11 as the initial deployment floors. These are recommendations for the capability spike, not a permanent compatibility promise.

Enable HealthKit and HealthKit background delivery for the iOS target. Enable HealthKit and workout processing for the watchOS target. Use the checked in property lists and entitlement files as the source of truth.

Keep HealthKit, WatchConnectivity, workout mirroring, and Apple framework types inside Apple adapters and application composition. Shared domain names must describe acquisition intent and semantics without assuming the device vendor.

Phase 0B contains no real HealthKit query, workout session, WatchConnectivity transfer, database, account, or backend. Those platform capabilities begin with physical device evidence in Phase 1. Select the Providence Apple developer team and keep its identifier in ignored local configuration only when physical signing begins.

The Watch target is provisionally configured as a companion that is not installed independently. This does not prevent an installed Watch application from buffering a measurement while its phone is temporarily unreachable. Independent installation and runtime disconnection are separate questions, and the final setting belongs to the Phase 1 capability evidence.
