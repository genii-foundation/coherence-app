# Coherence architecture overview

Status: Initial recommendation

Research checked on July 10, 2026.

## Executive recommendation

Build Coherence as a local first physiological measurement and reflection system. Its first job is to produce trustworthy, consented, timestamped evidence from one participant. Its second job is to combine several proven individual data spines into cautious group observations. It should not begin by claiming to measure presence, relationship quality, truthfulness, wisdom, or a single quantity called coherence.

The initial Apple implementation should have two native applications:

1. The Apple Watch application owns explicit measurement sessions, live sensor collection, immediate local buffering, and clear start, pause, stop, save, and discard controls.
2. The iPhone application owns HealthKit history, consent, durable storage, session labeling, BLE peripherals, export, eventual upload, personal timelines, and group enrollment.

Shared Swift modules provide the first implementation of acquisition ports and immutable data records. Canonical language neutral contracts will govern records that cross device, platform, or service boundaries. A backend enters only when a group pilot requires cross participant aggregation. Phase 0 should work without an account or server.

The most important architectural decision is also the least theatrical: do not build a coherence score. Preserve raw facts, provenance, quality, context, and uncertainty. Derived interpretation can improve later. Missing source data cannot.

## System boundary

Coherence is a focused instrument that may later supply evidence to the broader Providence ecosystem. It is not the whole Providence application described in the manuscripts. It is not a trust oracle, social credit layer, physiological wallet, or reputation system.

The recommended beachhead is retreat and gathering assisted personal reflection. The first technical milestone is still single participant because group mathematics cannot rescue unreliable individual acquisition. The first interpersonal milestone is an explicit event session in which each participant runs the same proven data spine on their own devices.

The product should use the word coherence as its mission and name. Initial measurements should use narrower labels such as individual state change, autonomic convergence, temporal synchrony, directional agreement, respiratory entrainment, and shared response.

## Constitutional principles

### Measurement is not meaning

A heart rate change is a measurement. Relaxation is an interpretation. Presence is a lived quality. The system must preserve this separation in its schemas, interfaces, and product language.

### Personal baselines precede group comparison

Raw heart rate and HRV values should not be compared between people. Every group input must first become a within person change using a disclosed baseline method and context such as time of day, sleep, movement, recent exercise, illness, medication, caffeine, or voluntary annotations.

### Consent is data, not a screen

Consent must be versioned and queryable by data class, capture intent, acquisition source, purpose, session, visibility, retention, raw or derived scope, research use, and future model use. A participant must be able to pause, leave, revoke, export, exclude, and delete.

### Acquisition continues without connectivity

The Watch must not depend on the iPhone being reachable. The iPhone must not depend on the backend being reachable. Every boundary uses durable local buffering, explicit acknowledgement, safe retry, and idempotent ingestion.

### Time uncertainty is part of every result

Keep source time, device wall time, host monotonic time, time zone, clock offset estimates, round trip latency, and offset uncertainty. Never overwrite a source timestamp during normalization. Group results must include clock uncertainty alongside signal uncertainty.

### Feedback must not quietly become an intervention

Showing people a live synchrony meter can change breathing, posture, attention, and behavior. That may be useful biofeedback, but it contaminates passive observation. Post session reflection should be the default. Live haptics, facilitator cues, and group displays should be explicit experimental modes with separate consent and study protocols.

### The system never ranks nervous systems

No leaderboards, weak participant labels, coherence grades, or hidden eligibility decisions should exist. Facilitators see aggregate quality and coverage by default. Identifiable physiology requires separate, revocable consent.

## Initial deployment model

### Apple Watch application

The Watch is the primary active measurement device.

It is responsible for:

1. Presenting an explicit, user visible session lifecycle.
2. Starting an appropriate `HKWorkoutSession` and `HKLiveWorkoutBuilder` only when the experience legitimately qualifies as a workout or supported health session.
3. Receiving live heart rate observations and selected motion context.
4. Capturing source time, arrival time, local monotonic time, quality, and battery diagnostics.
5. Sealing observations into immutable batches in a local append store.
6. Mirroring live state to the iPhone when reachable.
7. Delivering sealed batches later and retaining them until acknowledged.
8. Saving or discarding the HealthKit workout according to the participant's explicit choice.

Apple states that workout sessions generate high frequency heart rate samples and can continue in the background, but the app must make the workout state clear and support a proper save or discard lifecycle. See [Running workout sessions](https://developer.apple.com/documentation/healthkit/running-workout-sessions) and [Watch background sessions](https://developer.apple.com/documentation/watchkit/enabling-background-sessions).

### iPhone application

The phone is the participant's durable gateway.

It is responsible for:

1. Explaining and requesting staged HealthKit access.
2. Importing historical data through anchored queries and processing deletions.
3. Holding the durable personal timeline and session annotations.
4. Receiving live workout state for display and control.
5. Receiving durable sample batches from the Watch and deduplicating them.
6. Connecting to one participant's external BLE sensors in later phases.
7. Exporting normalized records and provenance as JSON or CSV.
8. Uploading consent eligible batches when a group pilot enables a backend.
9. Showing personal trends before, during, and after labeled sessions.
10. Showing quality, gaps, source, coverage, battery, and clock diagnostics.

### Shared Swift package

`packages/swift/CoherenceKit` is one local Swift package with several compile boundaries.

`CoherenceCore` owns provisional Swift models for sensor samples, batches, units, clocks, provenance, quality, consent, and session state. It depends only on Foundation and uses platform neutral terminology.

Acquisition records keep capture intent separate from acquisition source. Passive, explicit, imported, manual, and synthetic intent must not be conflated with a health repository, live wearable, direct peripheral, annotation, or synthetic generator. Transport is a third concern and belongs in delivery adapters.

`CoherenceAcquisition` owns platform neutral adapter ports. HealthKit, workout, motion, BLE, Health Connect, and manual annotation adapters implement those ports without changing the domain vocabulary.

`CoherenceData` owns append storage, migrations, repositories, import anchors, and deletion tombstones. Delivery state belongs to a destination aware outbox rather than the physiological sample store.

`CoherenceSync` owns envelopes, destination aware delivery outboxes, reconciliation, acknowledgements, and retry rules. Apple companion transfer and later backend upload are adapters over those semantics.

`CoherenceFeatures` owns deterministic, versioned feature calculations. It does not own product language or group interpretation.

SwiftUI screens, permission explanations, target lifecycle, and dependency composition stay in the application targets. The phone and Watch should not share interface code merely because Swift permits the mistake.

Apple recommends local packages for modular code developed with an app. See [Organizing code with local packages](https://developer.apple.com/documentation/xcode/organizing-your-code-with-local-packages).

### Platform and contract boundaries

Coherence is one product. `apps/apple`, future `apps/android`, and future `apps/web` identify implementation families. They are not separate product brands.

`packages/contracts` is the designated authority for language neutral schemas, semantic vocabularies, compatibility policy, and golden fixtures. The current Swift models remain provisional until a corresponding contract is accepted there. Default `Codable` behavior is not a wire specification because it does not settle timestamp precision, tagged unions, collection order, unknown values, or canonical digest bytes.

Before durable companion transfer leaves the capability spike, define canonical encoding and fixtures for the records it carries. Before local persistence stabilizes, add a stream manifest that connects each batch to participant scope, modality, source, unit, timebase, provenance, and sequence semantics. Before backend or Android synchronization, require an independent non Swift validator to pass the same fixtures.

Applications may depend on language packages. Language packages may implement canonical contracts. Services and clients share contracts and fixtures, never application source. Vendor specific framework types remain in adapters or namespaced provenance.

### Backend, when needed

Phase 0 and the early single participant data spine should not require a backend. A server becomes justified when participants join an event and consent to group aggregation.

The initial backend should contain:

1. A small identity service that maps accounts to pseudonymous participant identifiers.
2. A consent service with immutable receipts and revocation state.
3. An HTTPS ingestion service that accepts sealed batches with idempotency keys.
4. PostgreSQL for structured metadata, consent, sessions, batches, features, and deletion lineage.
5. Encrypted object storage only for raw arrays too large for ordinary relational rows.
6. A job queue for deterministic feature computation and aggregate recomputation.
7. A group aggregation service that enforces consent, minimum group policy, quality gates, and uncertainty reporting.
8. Audit logs for sensitive access and administrative actions.

Do not add TimescaleDB, Kafka, a feature store, or a machine learning platform until measured load and query patterns justify them. Distributed pageantry remains pageantry, even when it has a logo.

## End to end active session flow

1. The participant reviews session specific consent on the phone or Watch.
2. The Watch creates a local measurement session in the prepared state.
3. The participant explicitly starts collection.
4. The Watch starts the HealthKit workout session, builder, local stream, clock capture, and diagnostics.
5. Each observation becomes a normalized `SensorSample` with structured provenance and quality.
6. The Watch seals small ordered sets of samples into `SampleBatch` records.
7. Workout session mirroring sends current state and low latency observations to the phone when available.
8. The Watch persists every sealed batch before attempting transfer.
9. WatchConnectivity transfers sealed batches for durable delivery. The phone acknowledges a batch only after local commit.
10. The Watch keeps unacknowledged batches and retries later.
11. If group upload is enabled, the phone sends eligible batches with the same stable batch identifier and content digest.
12. The server returns an acknowledgement after durable commit. Repeated delivery returns the same logical result.
13. The participant ends the session and chooses save or discard for the workout.
14. The phone presents a private post session timeline with data coverage and uncertainty.
15. Group features are computed only from participants whose consent remains valid for that purpose.

## Apple platform findings

### Active heart rate

Apple's public path for dense watch heart rate is an explicit workout session. [Running workout sessions](https://developer.apple.com/documentation/healthkit/running-workout-sessions) says these sessions generate high frequency heart rate and continue receiving sensor data in the background. This supports the capability spike, but does not prove an exact cadence, gap rate, battery budget, or usefulness during conversation. Those are device experiments.

The app must not disguise ordinary life as exercise merely to keep sensors active. Every session needs a visible start and stop, a legitimate HealthKit activity choice, and measured App Review risk before product launch.

### Passive heart rate

Apple says background heart rate readings vary with activity outside workouts. See [Monitor heart rate with Apple Watch](https://support.apple.com/en-us/120277). Passive history is useful for longitudinal context and broad comparisons, not a continuous real time stream.

### Workout mirroring

Use HealthKit workout mirroring for live session coordination. [Building a multidevice workout app](https://developer.apple.com/documentation/healthkit/building-a-multidevice-workout-app) supports a primary Watch session mirrored to iPhone. The system can launch the iPhone app for a mirrored session and attempt reconnection after interruption. [Sending data to the remote workout session](https://developer.apple.com/documentation/healthkit/hkworkoutsession/sendtoremoteworkoutsession%28data%3Acompletion%3A%29) supports bidirectional session data.

Workout mirroring is a live channel, not the durable source of truth. The Watch local store remains authoritative for collection until the phone acknowledges a sealed batch.

### Durable Watch and phone transfer

Use WatchConnectivity for durable companion delivery. Apple's [Watch Connectivity transfer sample](https://developer.apple.com/documentation/watchconnectivity/transferring-data-with-watch-connectivity) distinguishes immediate messages from queued user information and file transfers. Use immediate messages only for ephemeral control. Use queued transfer for sealed batches and diagnostics.

The protocol should assume at least once delivery. Stable batch identifiers, content digests, and idempotent commits provide exactly one logical record without pretending the network provides exactly once transport.

### Historical HealthKit import

Use anchored queries per sample type and persist each query anchor only after the corresponding local transaction commits. [HKAnchoredObjectQuery](https://developer.apple.com/documentation/healthkit/hkanchoredobjectquery) returns additions, deletions, and a new anchor for the next incremental query.

Use observer queries as change notices, then run anchored queries for the actual data. [Executing observer queries](https://developer.apple.com/documentation/healthkit/executing-observer-queries) makes clear that the observer handler does not contain the changed samples and that background delivery has a maximum notification frequency. It is not a streaming transport.

HealthKit may be unavailable while the phone is locked because the store is encrypted. See [Protecting user privacy](https://developer.apple.com/documentation/healthkit/protecting-user-privacy). Background processing and local storage must tolerate deferred reads.

### Authorization behavior

Request access only when a feature needs it. HealthKit does not reveal whether read access was denied, and users can grant a limited historical window. See [Authorizing access to health data](https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data). Treat no returned samples as unknown, not proof that no health data exists.

### Initial HealthKit request set

Phase 0 should stage a narrow read request for:

1. Heart rate, for history and live workout observations.
2. Heart rate variability SDNN, as sparse Apple generated longitudinal context.
3. Resting heart rate, for personal baseline context.
4. Workouts, to relate signals to known activity and avoid false interpretations.
5. Respiratory rate, as available context rather than a guaranteed live stream.
6. Sleep analysis, for baseline conditioning.
7. Step count and active energy, for movement and exertion context.

The initial write request should cover only the workout and samples created by an explicit Coherence session. Manual labels belong in the Coherence store, not HealthKit.

Do not request ECG waveform, oxygen saturation, medication, clinical records, state of mind, audio, contacts, location, or unrelated health types in Phase 0. Add a type only with a user facing feature, a scientific reason, a retention rule, and a test plan.

Apple's [HRV SDNN type](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/heartratevariabilitysdnn) is a discrete HealthKit product. It is not an exposed continuous beat interval stream. Do not derive defensible RMSSD or beat to beat synchrony from sparse heart rate values.

## Data contracts

### Sensor sample

Each normalized sample should preserve:

1. Stable sample and stream identifiers.
2. Sensor kind, value shape, and native unit.
3. Original start and end times.
4. Device wall time at observation.
5. Host monotonic time when available.
6. Phone, Watch, sensor, or server offset estimates and uncertainty when available.
7. Capture intent, acquisition source, and optional nominal rate.
8. Sequence number when the source supplies or permits one.
9. Structured quality level and flags.
10. Namespaced source identity, version, device, hardware, software, original identifier, and source metadata.

The checked in provisional `SensorSample` model already represents these fields. Adapter specific raw metadata should be preserved in namespaced records rather than collapsed into one provenance score.

### Sample batch

A batch is an immutable delivery and storage unit. It has a stable identifier, one stream, optional session, schema version, creation time, content digest, and ordered samples.

Seal batches by a modest time or size threshold so that a crash loses little unsealed work and transfers remain efficient. The exact threshold belongs in the capability spike. Canonical encoding and digest rules must be specified before cross device deduplication is trusted.

### Session and event separation

Keep these concepts distinct:

1. An event is a retreat, gathering, study, or workshop.
2. A scheduled activity is a shared period such as meditation or discussion.
3. A measurement session is one participant's collection lifecycle.
4. A sensor stream is one source and modality within that measurement session.
5. An annotation is a participant or facilitator supplied fact with its own visibility.

This separation lets one participant reconnect, change sensors, or decline one modality without corrupting the shared event timeline.

## Local persistence

Use an explicit SQLite layer through GRDB after the native project is bootstrapped. Do not represent every high frequency observation as an independent SwiftData object.

Initial tables should cover participants, devices, consent receipts, events, scheduled activities, measurement sessions, sensor streams, sample batches, batch payloads, HealthKit anchors, annotations, clock estimates, upload attempts, acknowledgements, deletion requests, feature windows, and schema migrations.

The database is append oriented for acquisition, but deletion must be real. A deletion request should mark affected raw records, derived features, and group aggregates for secure purge and recomputation. Audit metadata may retain the fact that deletion occurred without retaining deleted physiology.

Use Apple Data Protection for database files and device bound Keychain material for credentials and any application encryption keys. GRDB does not encrypt a database by itself. The active buffer protection class must be tested while the phone is locked and the Watch session is running. Stronger file protection that blocks required background writes is not a security win if it silently discards measurements.

## Time synchronization

Time alignment is an independent subsystem, not a date field.

For each device pair and backend connection:

1. Exchange several timestamped ping and response messages.
2. Estimate offset with the midpoint of the lowest latency exchanges.
3. Record the round trip time and uncertainty instead of mutating sample times.
4. Recalculate periodically during long sessions.
5. Preserve clock estimate records with validity intervals.
6. Detect wall clock jumps by comparing them with the local monotonic clock.
7. Carry uncertainty into every group window and reject analysis when uncertainty exceeds the metric's time scale.

The Phase 0 export must include enough data to reproduce every alignment decision later.

## Sync semantics

The Watch to phone and phone to server protocols should share the same rules:

1. Delivery may repeat.
2. A stable batch identifier names one logical record.
3. A content digest detects identifier reuse with different contents.
4. The receiver commits before acknowledging.
5. The sender deletes only after durable acknowledgement and local retention policy permit it.
6. Retry uses capped exponential backoff with battery and network awareness.
7. Conflicting annotations use explicit versions rather than last write wins.
8. Deletion travels as a first class command and invalidates derived artifacts.
9. Protocol and schema versions are explicit in every envelope.

Direct Watch networking is not the initial default. It adds authentication, reachability, battery, and duplicate upload paths before the companion route is understood. The capability spike can test it as a fallback after mirrored workout and WatchConnectivity behavior are measured.

## Feature and group analysis model

Start with deterministic, inspectable individual features:

1. Mean heart rate.
2. Heart rate slope.
3. Resting heart rate deviation.
4. Sample coverage and gap rate.
5. Motion intensity.
6. RR interval quality when actual RR intervals exist.
7. RMSSD only from qualified beat intervals.
8. SDNN with method and window disclosed.
9. Change from a pre session or context conditioned personal baseline.

The first useful group outputs are:

1. Mean normalized state change.
2. Dispersion or convergence.
3. Directional agreement.
4. Pairwise time series association with disclosed lag search.
5. Subgroup structure.
6. Contributor count, coverage, and quality.
7. Null comparisons using time shifts, participant shuffling, and unrelated sessions.

Every result must include contributor count, capture intent, acquisition source class, quality threshold, coverage, clock uncertainty, statistical uncertainty, algorithm version, and exploratory or validated status.

Shared music, guided breathing, movement, posture, temperature, meals, schedule, and facilitator cues can create shared response without interpersonal coupling. Respiration and motion are especially important confounds. The product must never present a shared stimulus response as evidence that nervous systems directly influenced one another.

## Sensor roadmap

### Phase 0 and Phase 1

Use Apple Watch for convenience, live heart rate during explicit sessions, motion context, HealthKit history, and sparse HRV observations.

### Phase 2

Add generic Bluetooth Heart Rate Service support. The standard permits optional RR intervals and allows a sensor to drop old intervals when its buffer is full. See the [Bluetooth Heart Rate Service specification](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/HRS_v1.0/out/en/index-en.html).

Validate Polar H10 as the first reference device. Polar's current official SDK documents heart rate, RR intervals, ECG at 130 Hz, and accelerometer streams for H10. See [Polar BLE SDK](https://github.com/polarofficial/polar-ble-sdk) and [Polar H10 capabilities](https://github.com/polarofficial/polar-ble-sdk/blob/master/documentation/products/PolarH10.md).

Core Bluetooth supports background behavior and restoration, but it does not promise an immortal process. See [Core Bluetooth](https://developer.apple.com/documentation/corebluetooth) and [Bluetooth restoration rules](https://developer.apple.com/documentation/technotes/tn3115-bluetooth-state-restoration-app-relaunch-rules). The phone adapter needs restoration, packet loss accounting, reconnection, and user education about force quit behavior.

### Later modalities

Add respiration before interpreting cardiac synchrony deeply because paced breathing can produce it directly. Add EDA for arousal timing only, not emotional valence. Add voice only through a separate consent and legal flow, preferably with local feature extraction and raw audio discarded by default.

Treat EEG and other neurofeedback as a separate research program. The thesis manuscripts do not specify a concrete neural modality. Every device requires its own access, license, timestamp, artifact, battery, privacy, and validation spike. No generic `EEGAdapter` should create the illusion that those problems are solved.

Use explicit event codes, room identifiers, schedules, and participant confirmation before radio proximity. BLE zones may follow. UWB and inferred conversational grouping remain experiments after value is proven without them.

## Privacy, security, and product policy

Apple requires explicit type level HealthKit authorization, clear usage descriptions, a privacy policy, and health or fitness use. HealthKit data cannot be used for advertising or sold to data brokers. See [Protecting user privacy](https://developer.apple.com/documentation/healthkit/protecting-user-privacy) and the [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/).

Recommended defaults are:

1. No account and no server in Phase 0.
2. Pseudonymous identifiers in physiological records.
3. Raw physiology stays on participant devices unless a separate upload consent covers a named event and purpose.
4. Participants see their own individual results.
5. Facilitators and peers see eligible group aggregates only.
6. One on one and small group analysis requires explicit consent from every represented participant.
7. A configurable aggregate threshold begins at five for ordinary facilitator views.
8. No biometric content appears in push notifications, general analytics, or crash reports.
9. No advertising, behavioral marketing, physiology ranking, or engagement optimization.
10. No diagnostic, therapeutic, trauma, relationship quality, or mental health claims.
11. Research mode has separate consent, ethics review, withdrawal, export, and retention policy.
12. Deletion is tested across raw data, features, aggregates, backups, and audit boundaries.

Before any backend upload, complete a threat model for stolen devices, compromised accounts, malicious participants, overprivileged facilitators, backend breach, inference from small aggregates, consent replay, and deletion failure.

## Recommended product defaults

The unresolved brief decisions should begin with these working defaults:

1. Beachhead: gathering assisted personal reflection, followed by a retreat group pilot.
2. Compatibility: iOS 18 and watchOS 11 for the capability spike, revisited after device access and market analysis.
3. Account: local only use works without one; account creation begins when joining a group event.
4. Feedback: private post session reflection by default; live feedback is experimental.
5. Facilitator visibility: group aggregate only by default.
6. Cloud boundary: no server data in Phase 0; event specific consent before group upload.
7. Platform: Apple first for capability and scientific validation, while domain, storage, and protocol boundaries remain platform neutral from the beginning.
8. Watchless use: historical and annotation modes may work, but live Apple heart rate requires a supported source.
9. Group metrics: not required for the first technical milestone and not marketed as coherence until validated.
10. Battery and latency: measured over one, three, and six hour sessions before targets are promised.

## Monorepo evolution

Keep application composition separate from reusable capabilities.

The next likely additions are:

1. Canonical records and golden fixtures under `packages/contracts`, before durable protocols stabilize.
2. `services/ingestion`, when event upload begins.
3. `services/group-analysis`, after individual feature contracts stabilize.
4. `apps/web/facilitator`, if the group pilot needs a browser based facilitator surface.
5. `apps/apple/macos/research-capture`, if researchers need a controlled Apple desktop gateway.
6. `apps/android` and `packages/kotlin`, when the Android entry criteria in the roadmap are met.

Do not split the Swift package into several repositories. Coordinated schema, acquisition, and application changes are the point of this monorepo. Split only when ownership, release cadence, or security boundaries become materially different. See the accepted [platform boundary decision](decisions/0001-monorepo-platform-boundaries.md).

## Delivery sequence

### Foundation, complete in this initialization

The repository now has platform specific app roots, language specific package roots, a canonical contract boundary, target metadata, entitlements, shared module boundaries, provisional Swift data models, contract verification, validation scripts, continuous integration, and this architecture record.

### Native Apple project bootstrap

Accept the installed Xcode license and complete first launch setup. Create the iPhone application with a companion Watch target using Xcode's native template. Attach the checked in source roots and local Swift package. Commit the project and add simulator build validation.

### Phase 1 Apple capability spike

Follow [the capability spike plan](../roadmap/apple-capability-spike.md). The deliverable is an empirical matrix covering real devices, cadence, gaps, latency, background behavior, disconnection, reconciliation, provenance, battery, and export.

### Phase 2 individual data spine

Implement staged HealthKit history, SQLite persistence, local consent, session labels, durable Watch sync, export, personal timeline, and diagnostics.

### Phase 3 external heart sensor

Implement generic BLE heart rate and RR interval collection, then validate Polar H10 ECG and motion access separately.

### Phases 4 and 5 group pilot

Add event enrollment, explicit session schedule, consent eligible upload, delayed aggregation, facilitator coverage views, personal reflection, null comparisons, and deletion recomputation.

### Later research

Validate group metrics before proximity, voice, EDA, EEG, or composite models. Add one modality at a time and require each to earn its place.

## Current tooling constraint

This Mac now has Xcode 26.6, iOS and watchOS platform SDKs, and Swift 6.4 command line tools. Apple's Xcode license and first launch components still require administrator approval before command line or simulator builds can run.

The shared package remains testable through the command line toolchain. The repository checks in Apple application sources and exact target requirements, but does not contain a guessed project file. That is a deliberate correctness boundary, not an architectural omission.
