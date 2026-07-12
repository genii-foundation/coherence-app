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

## Staged privacy and authorization shell

The phone now presents a deliberate sequence before any Apple authorization sheet can appear:

1. A privacy explanation states that measurement is participant directed, access begins narrowly, and Apple keeps individual health read choices private from applications.
2. A requested access screen names each acquisition intent and its purpose.
3. A participant action invokes the authorization service. Completing the system request records that a request occurred. It does not prove that HealthKit read access was granted.
4. The overview reports readiness and sensor mode without inventing permission certainty.
5. A diagnostics screen previews and shares a privacy safe JSON capability snapshot.

The phone authorization plan currently requests read access to heart rate history only. The Watch plan requests read access to live heart rate and write access for an explicit workout. Preparing the Watch request does not begin a workout or collect samples.

Platform neutral authorization intents, readiness, observations, request records, errors, and the service protocol live in `CoherenceAcquisition`. The concrete `HealthKitMeasurementAuthorizationService` remains inside the Apple application boundary. It is the only authorization implementation in this slice that imports HealthKit. SwiftUI views receive projected domain state and do not call HealthKit directly.

[Apple's HealthKit authorization guidance](https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data) states that an application cannot determine whether a participant granted read access to an individual type. Read intents are therefore projected as `notInspectable`. The app may inspect its write authorization status for the workout type, but must not use request completion or the absence of an error as evidence of read permission.

## Synthetic sensor and authorization fixtures

Both shared schemes pass this Debug launch argument:

```text
COHERENCE_USE_FAKE_SENSORS=1
```

The argument selects a deterministic in memory sensor adapter and produces an unmistakably synthetic heart rate batch. Release builds ignore fake sensor selection. This is test composition, not a back door into HealthKit, which would be both architecturally wrong and impressively cursed.

Debug builds also accept one authorization fixture argument:

```text
COHERENCE_AUTHORIZATION_FIXTURE=<value>
```

Supported values are:

1. `needs-request`, which presents an authorization request as needed.
2. `request-recorded`, which presents a completed request while preserving read choices as noninspectable.
3. `write-denied`, which presents a recorded request with workout sharing denied.
4. `unavailable`, which presents HealthKit as unavailable.
5. `needs-companion`, which sends the participant to the device where collection belongs.
6. `request-failure`, which returns a stable sanitized failure code.

Fake sensor mode defaults to the `needs-request` authorization fixture when no fixture value is supplied. Fixtures use fixed run, request, and observation values so unit and interface tests are deterministic. Fixtures never replace physical HealthKit evidence.

## Privacy safe diagnostics

The phone diagnostic JSON contains application version and build, platform and device class, operating system version, the per-run identifier, sensor mode, authorization readiness, HealthKit availability, evidence source, requested acquisition intents, projected authorization observations, the latest request identifier and result when available, and a sanitized authorization error code.

The schema explicitly records that biometric values, participant identity, and persistent device identifiers are excluded. Tests also reject accidental sample and source timestamp fields in this export. The run identifier is fixed only for deterministic fixtures and is newly generated for a normal application launch. This initial redaction shape is not permission to add general telemetry. Export protection, retention, and diagnostic policy remain open architecture questions.

## Phase boundaries

Use iOS 18 and watchOS 11 as the initial deployment floors. These are recommendations for the capability spike, not a permanent compatibility promise.

Enable HealthKit and HealthKit background delivery for the iOS target. Enable HealthKit and workout processing for the watchOS target. Use the checked in property lists and entitlement files as the source of truth.

Keep HealthKit, WatchConnectivity, workout mirroring, and Apple framework types inside Apple adapters and application composition. Shared domain names must describe acquisition intent and semantics without assuming the device vendor.

Build Slice B adds a concrete HealthKit authorization adapter and the staged interface around it. It does not add a HealthKit sample query, workout session, live collection, WatchConnectivity transfer, database, account, or backend. Those capabilities still require Phase 1 physical device evidence. Select the Providence Apple developer team and keep its identifier in ignored local configuration only when physical signing begins.

Phase 1 remains Waiting. Current evidence is simulator safe composition. Root local validation passes with six phone tests and five Watch tests on a temporary paired simulator set. Hosted validation remains a merge gate and cannot substitute for physical authorization, collection, background, battery, or signing evidence.

The Watch target is provisionally configured as a companion that is not installed independently. This does not prevent an installed Watch application from buffering a measurement while its phone is temporarily unreachable. Independent installation and runtime disconnection are separate questions, and the final setting belongs to the Phase 1 capability evidence.
