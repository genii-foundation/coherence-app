# Xcode application roadmap

This document controls the first Apple implementation of Coherence. The [unified roadmap](README.md) controls phase order and cross platform gates. This document explains how the Xcode targets and Swift modules should evolve inside those phases. It does not define the product boundary or the canonical cross platform protocol.

## Native target graph

Create one committed Xcode project at `apps/apple/Coherence.xcodeproj`.

The initial targets are:

1. `CoherenceApp`, the iPhone application and primary composition root.
2. `CoherenceWatchApp`, the embedded watchOS companion and active measurement surface.
3. `CoherenceAppTests`, phone composition and platform integration tests.
4. `CoherenceAppUITests`, phone interface and lifecycle smoke tests.
5. `CoherenceWatchAppTests`, Watch composition, state projection, and adapter tests.

Do not add a Watch interface test target until it solves a concrete problem. Physical device protocols remain mandatory for HealthKit, connectivity, background, lock, and battery behavior.

The shared schemes are `Coherence` and `CoherenceWatch`. Check them into source control. Keep developer accounts, teams, personal schemes, and device identifiers out of the repository.

## Target dependencies

`CoherenceApp` links all five shared package products:

1. `CoherenceCore`
2. `CoherenceAcquisition`
3. `CoherenceData`
4. `CoherenceSync`
5. `CoherenceFeatures`

`CoherenceWatchApp` begins with:

1. `CoherenceCore`
2. `CoherenceAcquisition`
3. `CoherenceData`
4. `CoherenceSync`

Add `CoherenceFeatures` to Watch only when a measured low latency feature needs local computation. The phone remains the first home for personal feature computation.

Application targets own SwiftUI screens, lifecycle hooks, platform permission copy, and dependency composition. Shared modules own logic that is meaningful outside one screen or one executable. Apple adapters may name HealthKit, workouts, and WatchConnectivity. Core domain models may not.

## Application state architecture

Use SwiftUI and Observation without adopting a large application framework before the workflows require it.

Recommended boundaries are:

1. A `@MainActor` application model projects durable domain state into each interface.
2. Actor isolated services own HealthKit, workout lifecycle, WatchConnectivity, local storage, BLE, feature computation, and export.
3. Views send explicit intents to the application model and render immutable view state.
4. Platform callbacks are converted into domain events before interface code sees them.
5. Session lifecycle is stored as immutable events, then projected into the current state.
6. Every service has a protocol and a fake implementation before it is wired into a physical framework.

Do not place HealthKit queries, database transactions, or WatchConnectivity delegate logic directly in SwiftUI views. A view is a poor place to hide a distributed system, although generations of applications have tried with admirable confidence.

## Dependency composition

Each application target should have one composition root.

The phone composition root creates:

1. HealthKit authorization and historical import services.
2. Phone SQLite storage.
3. WatchConnectivity receiver and reconciliation engine.
4. Feature computation service.
5. Export service.
6. Account and cloud services only when Phase 4 begins.
7. One application model that receives those dependencies.

The Watch composition root creates:

1. Workout session service.
2. Live HealthKit adapter.
3. Motion adapter when the capability spike reaches it.
4. Compact Watch append store.
5. Workout mirroring coordinator.
6. WatchConnectivity batch sender.
7. One Watch application model that receives those dependencies.

Add a launch argument such as `COHERENCE_USE_FAKE_SENSORS=1` to select in memory adapters and deterministic clocks. Keep fake mode unavailable in production builds unless an explicit demo mode is later required for App Review.

## Build Slice A: Native project bootstrap

Roadmap phase: 0B

### Work

1. Accept the Xcode license and complete first launch setup.
2. Create a watchOS application with a companion iOS application.
3. Use organization identifier `org.providencecollective` provisionally.
4. Set application product name to `Coherence`.
5. Attach the checked in source, resource, property list, entitlement, and build configuration files.
6. Add the local `CoherenceKit` package.
7. Create and share the two schemes.
8. Add fake service composition.
9. Add phone and Watch smoke coverage.
10. Extend root validation and continuous integration.

### Validation

1. Both targets build from a clean checkout with signing disabled.
2. Both targets launch in paired simulators.
3. Both targets build and install on paired physical devices after local signing.
4. Embedded Watch bundle and companion identifiers are correct.
5. Generated signing entitlements contain only approved capabilities.

## Build Slice B: Permission and diagnostic shell

Roadmap phase: 1

### Phone work

1. Create a privacy explanation screen that precedes the system authorization sheet without imitating it.
2. Request the minimum first HealthKit types.
3. Show authorized feature readiness without claiming to know which read types were denied.
4. Add a diagnostic screen for application version, OS, device, permissions requested, and synthetic run identifier.
5. Add JSON diagnostic export with biometric values excluded.

### Watch work

1. Explain explicit measurement and workout behavior.
2. Request Watch HealthKit access at the moment collection becomes relevant.
3. Show ready, unavailable, and needs phone states without treating temporary disconnection as failure.

### Shared work

1. Define permission intents and readiness projections in platform neutral terms.
2. Add fake authorization outcomes for interface tests.
3. Record authorization requests as local events without claiming access was granted.

## Build Slice C: Explicit Watch session lifecycle

Roadmap phase: 1

### Watch work

1. Implement prepared, started, paused, resumed, ended, saved, discarded, and interrupted events.
2. Start `HKWorkoutSession` and `HKLiveWorkoutBuilder` from explicit participant intent.
3. Make recording state unmistakable.
4. Capture live heart rate with source and arrival timing.
5. Persist session events and samples before interface projection.
6. Add save and discard decisions with provisional local record behavior exposed for testing.
7. Handle wrist lowering and application backgrounding.

### Phone work

1. Display mirrored session state as a projection, not the source of truth.
2. Show connection and data freshness separately.
3. Never infer that a session ended merely because the Watch is unreachable.

### Validation

1. Deterministic state transition tests cover duplicates, out of order callbacks, interruption, and restart.
2. Physical tests cover screen sleep, backgrounding, lock, pause, save, and discard.

## Build Slice D: Live workout mirroring

Roadmap phase: 1

### Work

1. Register the phone mirroring handler at application launch.
2. Start mirroring from the Watch primary workout session.
3. Define a small versioned live envelope for state, diagnostic snapshots, and selected display data.
4. Treat repeated mirrored session objects as reconnection, not new measurement sessions.
5. Record message timing, failures, disconnects, and reconnection.
6. Keep live transport independent from durable batch state.

### Validation

1. Measure latency with phone foreground, background, locked, and temporarily disconnected.
2. Verify that Watch collection continues when mirroring fails.
3. Verify that reconnection does not duplicate session identity.

## Build Slice E: Durable Watch buffer and reconciliation

Roadmap phase: 1, promoted to production in Phase 2

### Watch work

1. Seal immutable batches with required content digests.
2. Commit a batch locally before scheduling transfer.
3. Retain it until phone acknowledgement.
4. Resume pending transfer after process restart.
5. Enforce measured storage and battery limits.

### Phone work

1. Receive queued batch transfers.
2. Verify schema, digest, stream identity, and ordering.
3. Commit idempotently before acknowledging.
4. Detect identifier reuse with different contents as a security and integrity event.
5. Preserve duplicate delivery diagnostics without duplicating physiological records.

### Validation

1. One hour offline buffering.
2. Process restart on both devices.
3. Reordered, repeated, corrupted, and delayed fixture delivery.
4. Low storage and partial write behavior.

## Build Slice F: Clock evidence

Roadmap phase: 1

### Work

1. Identify each local monotonic clock and epoch.
2. Exchange repeated Watch to phone timing probes.
3. Preserve offset, round trip time, uncertainty, measurement time, and validity.
4. Detect wall clock and time zone changes.
5. Export raw timing evidence.
6. Add server offset only when a backend exists.

### Validation

1. One, three, and six hour drift runs.
2. Phone disconnection and later reconciliation.
3. Device reboot and wall clock change fixtures.
4. Feature refusal when uncertainty exceeds the configured threshold.

## Build Slice G: Historical HealthKit spine

Roadmap phase: 2

### Work

1. Add one anchored importer per approved HealthKit type.
2. Persist each anchor in the same transaction as imported changes.
3. Process deleted objects and derived lineage invalidation.
4. Preserve every available source and device field.
5. Distinguish direct Watch collection from later HealthKit records for the saved workout.
6. Add observer queries as change notices only.
7. Tolerate locked HealthKit access and limited history.

### Validation

1. Initial import, incremental additions, deletion, restart, lock, and anchor corruption.
2. Duplicate avoidance when a direct Watch record later appears in HealthKit.
3. Several HealthKit sources producing the same type in the same interval.

## Build Slice H: Durable local product

Roadmap phase: 2

### Work

1. Implement GRDB migrations and repositories.
2. Decide and test Data Protection and database encryption.
3. Add consent receipts with capture intent, acquisition source, session, retention, representation, research, and model scopes.
4. Add session labels and annotation history.
5. Add transparent personal baseline features.
6. Build the personal timeline and quality explanations.
7. Add JSON and CSV export with a schema manifest.
8. Add local deletion, cryptographic key cleanup, and derived invalidation.
9. Add accessibility and localization readiness.

### Validation

1. Migration forward and rollback safety.
2. App and device restart.
3. Locked device background writes.
4. Low storage and database corruption recovery.
5. Export round trip and deletion completeness.

## Build Slice I: External heart sensor

Roadmap phase: 3

### Work

1. Add the generic BLE Heart Rate Service adapter first.
2. Add restoration, reconnection, packet loss, buffer overflow, battery, and firmware diagnostics.
3. Add qualified RR interval feature computation.
4. Add the Polar H10 capability adapter after license review.
5. Keep raw ECG in validation mode until product use is justified.

## Build Slice J: Event and cloud composition

Roadmap phase: 4

### Work

1. Add accounts only at group enrollment.
2. Add event codes, schedules, and scoped consent.
3. Add device registration, short lived tokens, revocation, and outbox upload.
4. Show upload, retention, exclusion, and deletion state to the participant.
5. Keep local only mode intact.

## Build Slice K: Group reflection

Roadmap phase: 5

### Work

1. Add private participant reflection before facilitator analytics.
2. Add facilitator aggregate coverage and uncertainty.
3. Add personal normalization, null models, and shared stimulus context.
4. Enforce group threshold, unanimous small group consent, and deletion recomputation.
5. Keep real time feedback out until Phase 6 experiments justify it.

## Phone interface roadmap

The phone interface should grow in this order:

1. Capability and privacy explanation.
2. Authorization readiness and diagnostics.
3. Current Watch session mirror.
4. Session label and save or discard resolution.
5. Private timeline with provenance and gaps.
6. Export and deletion controls.
7. External sensor setup.
8. Event enrollment and scoped upload.
9. Private group reflection.
10. Facilitator aggregate surface as a separate role or application.

Avoid a dashboard filled with metrics before the participant can understand where a number came from and what it cannot mean.

## Watch interface roadmap

The Watch interface should remain deliberately small:

1. Ready state and phone reachability.
2. Consent or permission handoff when required.
3. Explicit start.
4. Clear recording, quality, duration, connection, and battery state.
5. Pause and resume when the session model permits them.
6. End, save, or discard.
7. Reconciliation pending and completed state.
8. External sensor status only if the Watch later owns one.

Do not show a coherence score. During observational sessions, do not show physiological interpretation that changes behavior. Live intervention modes get their own interface and consent later.

## Test architecture

### Shared module verification

1. Swift model round trips and canonical contract fixture conformance.
2. Batch validation, digest conflict, ordering, and schema compatibility.
3. Consent scope evaluation.
4. Session event projection.
5. Clock offset, drift, uncertainty, and refusal fixtures.
6. Feature quality and coverage gates.

### Application unit tests

1. Composition with fake services.
2. Permission state projection.
3. Session lifecycle and recovery.
4. Connectivity state versus recording state.
5. Save, discard, export, and delete intents.

### Interface tests

1. Phone launch and privacy flow in fake mode.
2. Start and stop projection in fake mode.
3. Timeline gap and uncertainty explanation.
4. Export and deletion confirmation flows.

### Physical protocols

Use physical devices for HealthKit authorization, workout sensors, mirrored session launch, WatchConnectivity background tasks, lock, wrist state, Low Power Mode, Bluetooth restoration, cadence, latency, battery, thermal behavior, and App Review relevant behavior.

## Build configuration and continuous integration

Keep `config/apple/xcode/Base.xcconfig`, `Debug.xcconfig`, `Release.xcconfig`, and optional ignored `Local.xcconfig` as the shared settings source.

Continuous integration should eventually:

1. Pin macOS and Xcode versions.
2. Build every package product.
3. Run shared verification and native unit tests.
4. Build the iPhone target for a generic simulator with signing disabled.
5. Build the Watch target for a generic simulator with signing disabled.
6. Run phone interface smoke tests in fake mode.
7. Check package resolution and project changes.
8. Upload useful failure artifacts that contain no physiology.

## Tomorrow's exact starting point

After administrator approval is available:

1. Accept the installed Xcode license.
2. Complete first launch setup.
3. Verify iPhone and Watch simulator runtimes.
4. Create the native companion project in `apps/apple`.
5. Attach the existing sources and `packages/swift/CoherenceKit` package.
6. Wire capabilities and build settings.
7. Create shared schemes.
8. Build and launch both shells in paired simulators.
9. Build and launch them on paired physical devices.
10. Extend root validation and continuous integration.
11. Commit only the bootstrap.
12. Mark Phase 0B Complete and Phase 1 Ready in the unified roadmap.
