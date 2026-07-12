# Unified development roadmap

This is the controlling implementation roadmap for the Coherence ecosystem. When the instruction is "build the next phase," begin with the first phase marked Ready whose entry criteria are satisfied. Do not skip acceptance evidence or silently pull later research features into an earlier phase.

## Status rules

Every phase uses one of these states:

1. Complete means every exit criterion has evidence in the repository.
2. In progress means implementation has started and one named phase is active.
3. Ready means all entry criteria are satisfied.
4. Waiting means an external dependency or named decision is missing.
5. Deferred means the phase is intentionally outside the current product horizon.

At most one phase should be In progress. On phase completion, update this file, the [open technical questions register](../architecture/open-technical-questions.md), relevant decision records, and validation commands.

## Current position

Phase 0A is Complete.

Phase 0B is Complete. The native target graph, deterministic simulator composition, paired simulator validation, and pinned continuous integration are in the repository.

Phase 1 is Waiting for a selected Apple developer team, local physical signing, and a paired physical iPhone and Apple Watch. It becomes Ready only when every entry criterion below is satisfied.

## Phase 0A: Repository and architecture foundation

Status: Complete

### Objective

Create a cross platform monorepo foundation that can host the first native Apple applications, future Android and web applications, language specific implementations, canonical contracts, research tools, and eventual backend services.

### Delivered scope

1. Platform specific iPhone and Apple Watch source roots, property lists, and HealthKit entitlements under `apps/apple`.
2. A shared local Swift package under `packages/swift` with Core, Acquisition, Data, Sync, and Features boundaries.
3. Provisional versioned sample, batch, provenance, clock, quality, consent, session, sync, and feature models.
4. Shared package contract verification and continuous integration.
5. A thesis grounded architecture overview and source map.
6. A physical device capability spike protocol.
7. This unified roadmap and the living technical questions register.
8. An accepted platform boundary decision and a designated canonical contract home under `packages/contracts`.

### Exit evidence

1. `scripts/validate.sh` builds every shared module and verifies the core data contracts.
2. `scripts/doctor.sh` reports the local Apple toolchain state.
3. All current source and architecture documents are committed together.

## Phase 0B: Native Xcode application bootstrap

Status: Complete

### Objective

Create a trustworthy native target graph for the iPhone application and its companion Apple Watch application, then prove both shells build on current simulators.

### Entry criteria

1. A supported command line Xcode toolchain is installed and selected.
2. Xcode license and first launch setup are complete for command line builds.
3. iOS and watchOS platform SDKs and simulators are available.
4. Phase 0A validation is green.

### Implementation scope

1. Define the native companion target graph in `apps/apple/project.yml` and generate it with XcodeGen 2.45.4.
2. Create `CoherenceApp`, `CoherenceWatchApp`, `CoherenceAppTests`, `CoherenceAppUITests`, and `CoherenceWatchAppTests` targets.
3. Use iOS 18 and watchOS 11 as provisional deployment floors.
4. Attach the existing application sources, resources, property lists, and entitlements.
5. Add the local `CoherenceKit` package.
6. Link every shared module to the phone target and only required modules to the Watch target.
7. Apply checked in base, debug, and release settings.
8. Create shared `Coherence` and `CoherenceWatch` schemes.
9. Add a launch argument that selects fake sensor adapters for simulator tests.
10. Add phone composition and interface smoke tests plus a Watch composition test.
11. Extend `scripts/validate.sh` to build both application targets with signing disabled and run simulator tests.
12. Pin the continuous integration runner, Xcode, and XcodeGen versions.
13. Commit the generated Xcode project and its specification.

### Exit criteria

1. The iPhone shell builds and launches in an iOS simulator.
2. The Watch shell builds and launches in a paired watchOS simulator.
3. The iPhone application embeds the correct companion Watch application.
4. The local Swift package resolves without drift.
5. Fake sensor mode works without HealthKit authorization.
6. Unit and interface smoke tests pass.
7. The root validation command exercises package, phone, and Watch code.
8. A new developer can open the project and reach the same result from checked in instructions.

### Exit evidence

1. `apps/apple/project.yml` defines all five targets, both shared schemes, package links, bundle identifiers, and the embedded Watch dependency.
2. `scripts/generate-apple-project.sh` pins XcodeGen 2.45.4 and reproduces `apps/apple/Coherence.xcodeproj`.
3. `scripts/validate-apple.sh` builds both schemes with signing disabled, verifies Watch embedding and identifiers, boots a temporary paired simulator set, and runs native unit and interface smoke tests.
4. `scripts/validate.sh` runs shared contract verification before native application validation.
5. Continuous integration pins Xcode 26.6 on macOS 26 and rejects generated project drift.

### Explicit exclusions

No real HealthKit query, workout session, WatchConnectivity transfer, database, account, or backend belongs in this phase.

## Phase 1: Apple capability spike

Status: Waiting for physical device signing and setup

### Objective

Measure what current Apple hardware and public APIs actually support before designing production acquisition behavior.

### Entry criteria

1. Phase 0B is Complete.
2. At least one physical iPhone and paired Apple Watch are available.
3. The Providence Apple developer team is selected and local signing succeeds for both applications.
4. A synthetic participant and redacted export location are defined.
5. The [capability spike protocol](apple-capability-spike.md) is reviewed.

### Xcode application work

1. Add a staged HealthKit authorization coordinator.
2. Implement anchored historical imports for heart rate and HRV SDNN first.
3. Capture every available source revision, device, UUID, metadata, and algorithm version field.
4. Implement an explicit Watch workout lifecycle with prepared, recording, paused, ended, saved, and discarded states.
5. Collect live heart rate through `HKLiveWorkoutBuilder`.
6. Capture source, wall, monotonic, and arrival timestamps.
7. Add local diagnostic logging with sensitive values redacted.
8. Mirror the active workout session to the phone.
9. Send live diagnostic snapshots through the mirrored session.
10. Buffer sealed sample batches on the Watch.
11. Transfer sealed batches through WatchConnectivity and acknowledge only after phone persistence.
12. Export a complete run bundle as JSON.
13. Add battery, thermal, cadence, gap, latency, connectivity, and clock uncertainty diagnostics.
14. Add deliberate disruption controls for development builds.

### Contract work

1. Decide the initial canonical representation for streams, samples, batches, acknowledgements, and session events.
2. Define timestamp, identifier, unit, ordering, unknown value, and digest rules under `packages/contracts`.
3. Add golden valid, invalid, corruption, and prior version fixtures.
4. Make the Swift encoder and decoder pass those fixtures.
5. Keep HealthKit, workout, Apple Watch, and WatchConnectivity names in Apple adapters or namespaced provenance.

### Physical experiments

Run quiet rest, conversation, paced breathing, meditation or Qigong, walking, a meal period, screen sleep, phone lock, temporary phone disconnection, Watch backgrounding, and reconnection.

Run one, three, and six hour battery sessions on the oldest supported Watch and at least one recent Watch. Add a current Ultra when available.

### Exit criteria

1. Every capability question in the spike protocol has evidence, an explicit unsupported result, or an explicit inconclusive result.
2. Historical import resumes without logical duplicates and processes deletions.
3. Live Watch samples survive screen sleep and measured connection interruptions.
4. One hour of Watch buffering reconciles to one logical phone copy per batch.
5. Clock uncertainty is exported and visible.
6. Battery and sampling reports cover one, three, and six hours.
7. App lifecycle behavior is documented for normal exit, crash, and force quit.
8. The repository contains a go, revise, or stop decision for Phase 2.
9. Durable transfer records have accepted canonical encoding rules and Swift conformance fixtures.

### Decisions closed in this phase

1. Supported minimum OS and practical device floor.
2. Legitimate HealthKit activity type and App Review posture.
3. Workout mirroring and WatchConnectivity responsibilities.
4. Initial batch size and flush interval.
5. Active buffer file protection class.
6. Measured battery and latency budgets.
7. Initial HealthKit read and write set.
8. Initial durable contract representation, digest rules, and compatibility window.

## Phase 2: Local single participant data spine

Status: Waiting for Phase 1

### Objective

Turn the capability prototype into a reliable, private personal measurement product that works offline without an account.

### Entry criteria

1. Phase 1 produces a go or bounded revise decision.
2. Source of truth, local encryption, deletion, schema, and conformance questions have provisional decision records.
3. A stream manifest defines participant scope, source, modality, unit, timebase, provenance, and sequence semantics.
4. Append only physiological storage is separate from destination aware delivery outboxes.
5. The chosen SQLite approach passes locked device and background write tests.

### Xcode application work

1. Implement GRDB backed append storage and versioned migrations.
2. Add repositories for sessions, streams, batches, anchors, annotations, features, clock estimates, acknowledgements, and deletion state.
3. Implement staged HealthKit history for the approved sample types.
4. Add incremental observer and anchored query coordination.
5. Implement the production Watch local store and phone reconciliation engine.
6. Add local consent receipts and per modality controls.
7. Add session labels such as meditation, Qigong, discussion, meal, exercise, rest, and sleep.
8. Build a personal timeline with before, during, and after windows.
9. Add deterministic heart rate, coverage, gap, motion, and baseline features.
10. Add JSON and CSV exports with provenance and algorithm versions.
11. Add inspect, pause, exclude, export, and delete controls.
12. Add a privacy safe diagnostics bundle.
13. Add migrations, interruption, corruption, and low storage tests.
14. Add accessibility, localization readiness, and interface state tests.
15. Preserve canonical contract fixtures as persistence and export formats evolve.

### Exit criteria

1. A participant can install both applications, authorize selected data, and remain local only.
2. Historical imports resume without duplication.
3. A live Watch session survives temporary phone loss and reconciles correctly.
4. At least one hour buffers locally under the measured battery budget.
5. The personal timeline clearly distinguishes source data, derived features, gaps, and uncertainty.
6. Export reproduces normalized records and provenance.
7. Deletion removes raw and derived local data according to policy.
8. No backend, group inference, or medical claim is required.

### Decisions closed in this phase

1. Local database schema and migration discipline.
2. HealthKit versus Coherence record authority by data class.
3. Local key and file protection model.
4. Personal baseline version 1.
5. On device retention and export policy.

## Phase 3: External heart sensor and qualified HRV

Status: Waiting for Phase 2

### Objective

Add actual RR interval acquisition and validate serious HRV features without pretending sparse Apple heart rate is beat level data.

### Entry criteria

1. Phase 2 is Complete.
2. Generic BLE Heart Rate Service behavior and background restoration have approved test protocols.
3. Polar SDK license, current API, and data access terms are reviewed.
4. At least one reference chest strap is available.

### Xcode application work

1. Implement a generic BLE Heart Rate Service adapter.
2. Parse heart rate, optional RR intervals, energy, sensor location, and battery data.
3. Add packet loss, duplicate, overflow, reconnection, and restoration accounting.
4. Make the phone the participant's local BLE gateway.
5. Add Polar H10 support as a separate adapter or approved SDK integration.
6. Compare generic RR, Polar ECG, and Watch heart rate on aligned timelines.
7. Implement qualified RMSSD and related deterministic features with artifact rules.
8. Reject feature windows that fail coverage or quality thresholds.
9. Export raw RR intervals, quality decisions, and algorithm versions.

### Exit criteria

1. RR interval capture survives backgrounding and measured reconnection cases.
2. Packet loss and discarded sensor buffer data are visible.
3. HRV features run only on qualified source data.
4. Apple Watch and chest strap comparison results are documented.
5. The product clearly distinguishes convenient Watch heart rate from qualified RR based HRV.

## Phase 4: Account, cloud ingestion, and event enrollment

Status: Waiting for Phase 2 and cloud decisions

### Objective

Add the smallest backend required for consented multi participant events without making the server the silent owner of personal physiology.

### Entry criteria

1. Phase 2 is Complete. Phase 3 may proceed in parallel only after schemas are stable.
2. `packages/contracts` is authoritative for every uploaded record and its compatibility policy.
3. At least one independent non Swift validator passes all accepted contract fixtures.
4. Identity, cloud topology, server retention, residency, consent, deletion, and threat model decisions are approved.
5. A group pilot has a named use case and participant policy.

### Client work

1. Keep local only mode available.
2. Add account creation at event enrollment, not application launch.
3. Add session codes or QR enrollment.
4. Add event, activity, and participant consent receipts.
5. Add an outbox with idempotent, resumable, encrypted upload.
6. Add device registration, short lived tokens, revocation, and recovery.
7. Add server acknowledgement and deletion propagation.
8. Show exactly which data is queued, uploaded, retained, or excluded.

### Service work

1. Implement identity to pseudonym mapping as a separate boundary.
2. Implement consent and policy version storage.
3. Implement authenticated HTTPS batch ingestion with content digest verification.
4. Store structured metadata in PostgreSQL.
5. Add object storage only for large raw arrays.
6. Add audit logs, rate limits, tenant isolation, and administrative least privilege.
7. Implement participant export and deletion workflows before pilot upload.

### Exit criteria

1. Local only use remains functional.
2. An enrolled participant uploads only consent eligible records.
3. Retries produce one logical server copy.
4. Device revocation and token expiry are tested.
5. Participant export and deletion work across device and server records.
6. No facilitator can inspect individual physiology through ordinary product access.
7. A backend compromise and aggregate inference threat model is reviewed.

## Phase 5: Group session foundation and delayed aggregation

Status: Waiting for Phase 4

### Objective

Combine several participant data spines into transparent, delayed group observations with strict consent and coverage rules.

### Implementation scope

1. Add shared event schedules and facilitator annotations.
2. Align participant windows with recorded clock uncertainty.
3. Normalize every participant against their own approved baseline.
4. Compute mean normalized state change, dispersion, directional agreement, pairwise association, subgroup structure, and coverage.
5. Add time shift, participant shuffle, and unrelated session null comparisons.
6. Add algorithm and feature lineage so deletion triggers recomputation.
7. Build private participant reflection first.
8. Build a facilitator view that shows aggregates, coverage, uncertainty, and missingness.
9. Enforce a configurable ordinary aggregate minimum that begins at five.
10. Require unanimous explicit consent for named pairwise or small group analysis.

### Exit criteria

1. A pilot event completes despite intermittent connectivity.
2. Every aggregate exposes contributors, quality, coverage, uncertainty, and algorithm version.
3. No result can be traced to one participant through the ordinary interface.
4. Shared stimulus and movement confounds are visible.
5. Participant deletion invalidates and recomputes affected aggregates.
6. Product language remains exploratory and nonmedical.

## Parallel Android delivery track

Status: Waiting for product trigger and contract readiness

Android is a planned Coherence implementation. It is not deferred until ecosystem hardening, and it does not need to mimic every Apple capability before delivering value.

### Entry criteria

1. Phase 1 has measured the Apple acquisition assumptions that inform parity decisions.
2. A named pilot, reach goal, or Android specific capability justifies implementation.
3. `packages/contracts` covers the records the Android client will store or synchronize.
4. OTQ-028 has an approved entry decision and capability spike plan.
5. Kotlin conformance tests can run against the canonical fixtures.

### Delivery stages

1. Create `apps/android` and `packages/kotlin` only when implementation starts.
2. Run a phone and wearable capability spike covering Health Connect, Wear OS, BLE, background execution, timestamp quality, battery, and repository deletion behavior.
3. Ship the smallest useful Android surface, which may begin with history, annotations, event enrollment, exports, or external BLE sensing.
4. Add wearable live acquisition only where measured platform behavior supports the same quality and consent promises.
5. Keep platform capability classes visible so group analysis never treats unlike sources as equivalent by wishful thinking.
6. Require Kotlin to pass the same valid, invalid, compatibility, digest, and unknown value fixtures before synchronization ships.

### Exit criteria for interoperable Android synchronization

1. Android records preserve the same provenance, timing, consent, deletion, and uncertainty semantics.
2. Swift, Kotlin, and service validators agree on canonical bytes and digests.
3. Cross version synchronization passes the approved compatibility matrix.
4. Platform specific quality differences are represented explicitly in analysis inputs.

## Phase 6: Scientific validation and feedback experiments

Status: Waiting for Phase 5

### Objective

Determine which measurements are useful, which are misleading, and whether live or delayed feedback improves participant outcomes without manufacturing the signal.

### Implementation and study scope

1. Separate product and research modes.
2. Predefine hypotheses, metrics, exclusion rules, null models, and failure criteria.
3. Add participant reported experience and facilitator annotations.
4. Compare rest, paced breathing, conversation, meditation, Qigong, walking, meals, music, and control periods.
5. Compare passive Watch, active Watch, chest strap RR, and reference ECG when available.
6. Run post session reflection as the default condition.
7. Test live personal, live dyadic, and facilitator feedback only as explicit experimental arms.
8. Publish methods, error rates, negative results, and versioned algorithms.

### Exit criteria

1. Independent scientific review supports every marketed group claim.
2. Validated metrics have disclosed sensitivity, specificity where applicable, uncertainty, confounds, and failure cases.
3. Exploratory metrics remain visibly separate.
4. The project has explicit evidence for continuing, revising, or rejecting each feedback mode.

## Phase 7: Proximity and conversational episode research

Status: Deferred

### Objective

Test whether proximity adds enough value to justify its privacy, battery, and inference cost.

Begin with explicit room codes, schedules, zones, and participant confirmation. Then test BLE zone inference. Prototype selected UWB ranging only after coarse proximity is useful. Never promise invisible, continuous conversation surveillance.

Exit requires participant control, visible uncertainty, rapid expiry, confirmation, and proof that the feature improves analysis beyond explicit context.

## Phase 8: Multimodal and neurofeedback research

Status: Deferred

### Objective

Add one independently justified modality at a time.

Respiration should come first because it is both meaningful and a major cardiac confound. EDA may follow for arousal timing. Voice needs separate recording consent and local feature extraction. EEG, fNIRS, and other neurofeedback need an independent scientific program because the thesis manuscripts do not specify a concrete neural modality.

Each modality needs a hardware access spike, license review, timestamp study, artifact model, battery study, consent flow, retention rule, validation protocol, and explicit stop criterion.

## Phase 9: Production ecosystem hardening

Status: Deferred

### Objective

Prepare validated capabilities for broader deployment and complementary applications.

Potential work includes facilitator applications, research capture tools, international residency, advanced recovery, operational monitoring, customer administration, store production review across active platforms, external security assessment, legal review, and hardening of every implementation already justified by evidence.

This phase does not begin until the scientific and privacy foundations survive real pilots. Scale is not a substitute for being right. It merely distributes the error more efficiently.

## Cross phase requirements

Every phase must preserve these requirements:

1. No new HealthKit type without a user feature, scientific reason, consent scope, and test.
2. No new derived feature without algorithm version, source lineage, quality threshold, and fixtures.
3. No upload without purpose, retention, deletion, and participant visibility.
4. No group result without participant count, coverage, uncertainty, and consent enforcement.
5. No schema migration without backward and forward compatibility evidence.
6. No background execution claim without physical device evidence.
7. No sensitive value in push notifications, general analytics, or crash reports.
8. No medical, emotional truth, relationship quality, or physiological ranking claim.
9. No closed technical question without a decision record.
10. No completed phase without an updated roadmap and validation evidence.
11. No vendor API name or serialization default becomes a canonical domain or wire contract.
12. No interoperable implementation ships without passing the shared conformance fixtures.
