# Open technical questions

Last reviewed: July 10, 2026

This is the living register for unresolved product, scientific, security, privacy, data, and platform architecture questions. A question remains here after it is decided, with its status changed to Decided and a link to the decision record. This preserves the history of what was uncertain and why the project chose a path.

## Working method

Use these statuses:

1. Open means the question is not ready for a decision.
2. Investigating means an experiment or focused research task is active.
3. Proposed means enough evidence exists for review.
4. Decided means an approved record exists under `docs/architecture/decisions`.
5. Deferred means the question has a named future phase and does not block current work.

Every investigation should identify an owner, evidence, decision deadline, and affected roadmap phase. Close a question with a decision record based on the [decision template](decisions/0000-template.md). Do not quietly convert a provisional recommendation in the architecture overview into settled policy.

## Questions that block the next two phases

The following questions deserve first attention:

1. OTQ-001, authority by data class.
2. OTQ-005, local storage encryption and locked device access.
3. OTQ-009, Watch to phone live and durable transport.
4. OTQ-011, time synchronization and uncertainty limits.
5. OTQ-013, legitimate workout classification.
6. OTQ-014, initial HealthKit authorization set.
7. OTQ-015, device and operating system floor.
8. OTQ-017, personal baseline version 1.
9. OTQ-018, feedback timing.

## Data authority and provenance

### OTQ-001: Which system is authoritative for each data class?

Status: Open

Decision deadline: Phase 2 entry

Current leaning: Avoid declaring one universal source of truth. Use explicit authority by record type.

HealthKit is likely authoritative for samples and deletions it manages. The Coherence local store is likely authoritative for session boundaries, consent receipts, annotations, normalized acquisition records, transfer state, quality decisions, and derived features. A future server is likely authoritative only for the exact uploaded batch, server acknowledgement, event policy, and group outputs it computes.

Questions:

1. Must deletion of a HealthKit sample remove its normalized Coherence copy and every derived result?
2. Is the Watch local buffer authoritative before a workout is saved to HealthKit?
3. Should Coherence write live observations to HealthKit, or save only the workout while retaining its own normalized record?
4. Where do external BLE samples live if they are not written to HealthKit?
5. Can HealthKit remain the personal archive if Coherence needs provenance, transfer, and clock fields that HealthKit does not store?
6. What is authoritative when a participant edits a label or correction?

Evidence needed: HealthKit deletion and UUID behavior, export requirements, locked device behavior, actual workout save semantics, and legal review of local and server copies.

### OTQ-002: What does participant ownership mean technically?

Status: Open

Decision deadline: Phase 2 exit

Current leaning: Participants can inspect, export, exclude, and delete local data without an account. Server use requires explicit event and purpose consent. Data portability should use documented, versioned formats.

Questions:

1. Can the participant export every raw, normalized, derived, consent, and provenance record?
2. Which administrative metadata remains after deletion?
3. Can a participant correct context without rewriting raw measurements?
4. How is consent withdrawal represented when prior aggregate publication cannot be recalled?
5. Does device loss imply data loss in local only mode, or is an encrypted participant backup offered later?

### OTQ-003: How strong is provenance, and how is confidence represented?

Status: Open

Decision deadline: Phase 1 exit

Current leaning: Store structured facts, never a magic provenance score. HealthKit source revision, device, UUID, metadata, algorithm version, application version, collection mode, and import path are evidence, not cryptographic attestation.

Questions:

1. Which fields are present and stable for each HealthKit type?
2. How are duplicate values from multiple devices distinguished?
3. Can a third party app write a record that resembles an Apple Watch record?
4. Which external sensors provide device identity, firmware, sequence, and quality information?
5. Do research exports need signatures from the collecting device?
6. How is manual or synthetic test data unmistakably labeled?

### OTQ-004: What is the canonical sample and batch encoding?

Status: Open

Decision deadline: Phase 1 exit

Current leaning: Swift domain types are the current semantic source. Durable transfer needs a canonical binary or JSON encoding, stable field identifiers, explicit units, schema version, and SHA-256 content digest.

Questions:

1. Is JSON sufficient for Watch batches and scientific export?
2. Should high frequency arrays use CBOR, Protocol Buffers, FlatBuffers, or compressed columnar payloads?
3. How are unknown future sensor kinds preserved across old clients?
4. What compatibility window must clients and services support?
5. Which fields participate in the content digest?
6. How are floating point values normalized for a stable digest?

## Local security and storage

### OTQ-005: How should local biometric storage be encrypted?

Status: Open

Decision deadline: Phase 2 entry

Current leaning: Use Apple Data Protection for database files, device bound Keychain material for credentials and application keys, and an explicit decision about database level encryption. GRDB alone does not encrypt SQLite.

Questions:

1. Does Data Protection satisfy the product threat model, or is SQLCipher or encrypted payload storage required?
2. Which file protection class permits required Watch and locked phone writes?
3. How are temporary exports and diagnostic bundles protected?
4. How are keys deleted when a participant deletes all local data?
5. Can backups include the database, and under what encryption and restore rules?
6. What happens when protected data is unavailable during a background callback?

Evidence needed: physical device lock tests, background write tests, backup inspection, performance measurements, and a written stolen device threat model.

### OTQ-006: What is the device key and account recovery model?

Status: Deferred to Phase 4

Decision deadline: Phase 4 entry

Questions:

1. Does each installation create a device key pair?
2. Can a new device recover encrypted personal data without giving the service provider a universal decryption key?
3. How are lost devices revoked?
4. What can be recovered in local only mode?
5. Is Sign in with Apple sufficient identity, or is passkey support required?
6. How are account deletion and cryptographic erasure coordinated?

### OTQ-007: What belongs in logs, analytics, and crash reports?

Status: Open

Decision deadline: Phase 1 entry

Current leaning: No biometric values, raw timestamps tied to identity, HealthKit metadata, consent contents, session labels, or peer identifiers leave the device through general telemetry.

Questions:

1. Can diagnostics use pseudonymous run identifiers without creating tracking identifiers?
2. Which event names reveal sensitive session context?
3. How are local logs rotated and exported with explicit review?
4. What redaction tests run in continuous integration?
5. Which third party SDKs are forbidden from sensitive targets?

### OTQ-008: What is the initial security review boundary?

Status: Open

Decision deadline: Phase 2 exit

Questions:

1. Which assets and adversaries belong in the first threat model?
2. When is an external mobile security review required?
3. What secure development controls gate new sensor SDKs?
4. How are dependency provenance and software bills of materials tracked?
5. Which security failures stop a pilot?

## Device and network synchronization

### OTQ-009: Which channel owns live state and which owns durable transfer?

Status: Investigating in Phase 1

Decision deadline: Phase 1 exit

Current leaning: HealthKit workout mirroring owns live session state and low latency display. WatchConnectivity owns durable sealed batches and diagnostics. The Watch store remains authoritative until phone acknowledgement.

Questions:

1. Which messages can workout mirroring lose, repeat, or reorder?
2. Does the system wake and reconnect the phone reliably in tested conditions?
3. Should small sealed batches use queued user information or file transfer?
4. How are acknowledgements retried without message storms?
5. How does the phone distinguish active session state from durable acquisition state?
6. When can the Watch safely purge acknowledged batches?

### OTQ-010: Should group synchronization use cloud, peer to peer, or a hybrid?

Status: Open

Decision deadline: Phase 4 entry

Current leaning: Use each phone as its participant's local gateway, then upload consent eligible batches to a backend when connectivity exists. Do not make peer to peer device exchange the primary group path until privacy, identity, reliability, and scale are proven.

Questions:

1. What user value requires real time cloud aggregation rather than delayed upload?
2. Can a facilitator device collect batches locally without becoming a sensitive central honeypot?
3. Does peer to peer exchange reveal the social graph or individual state?
4. How do participants authenticate peers without a server?
5. How does a disconnected retreat reconcile after devices leave the venue?
6. Is a local venue gateway useful for research deployments?
7. What is the failure behavior when two phones upload the same Watch batch?
8. Which topology supports participant deletion and audit most reliably?

### OTQ-011: How precise must clock synchronization be?

Status: Investigating in Phase 1

Decision deadline: Phase 1 exit for cardiac windows, revisited per modality

Current leaning: Preserve all source times, estimate offsets through repeated low latency exchanges, store uncertainty, and reject analysis when uncertainty is large relative to the feature window.

Questions:

1. What timing error is acceptable for heart rate trend, RR interval, respiration, motion, EDA, voice, and EEG features?
2. How stable are Watch and phone offsets over six hours?
3. Can server time improve alignment after offline collection?
4. How are wall clock jumps detected and repaired without rewriting source time?
5. Which clock estimate applies to a batch spanning an offset update?
6. How should the interface explain uncertain alignment?

### OTQ-012: What are the exact idempotency and conflict rules?

Status: Open

Decision deadline: Phase 2 entry for Watch sync, Phase 4 entry for cloud sync

Questions:

1. Is the batch identifier random, time sortable, or deterministically derived?
2. What happens when the same identifier arrives with a different digest?
3. Can annotations be edited, and if so, how are versions merged?
4. Which deletions win over late arriving batches?
5. How long are sender acknowledgements retained?
6. How is partial batch corruption handled?

## Apple platform and product behavior

### OTQ-013: What HealthKit workout classification is legitimate?

Status: Investigating in Phase 1

Decision deadline: Phase 1 exit

Current leaning: An explicit user visible session is mandatory. The app should not classify ordinary conversation or meals as exercise solely to increase sensor frequency. Candidate activity types need device tests and App Review analysis.

Questions:

1. Is mind and body appropriate for meditation, Qigong, or facilitated practice?
2. What should a conversation measurement session save to HealthKit?
3. Can one product support observational and active practice modes without misclassification?
4. Does saving a workout contaminate activity rings or health summaries?
5. Should the participant be able to discard the HealthKit workout while keeping a private Coherence record?
6. When a participant discards a session, which normalized samples, diagnostics, consent facts, and derived records remain locally?

### OTQ-014: Which HealthKit types should be requested, read, and written?

Status: Open

Decision deadline: Phase 1 exit

Current leaning: Begin with heart rate, HRV SDNN, resting heart rate, workouts, respiratory rate, sleep analysis, step count, and active energy as staged reads. Write only explicit Coherence workout outputs required by the tested session model.

Questions:

1. Which types provide enough user value to justify the permission?
2. Which types are unavailable or inconsistent across supported devices?
3. How does limited history affect baselines?
4. Should mindful sessions be read or written?
5. Does adding motion through Core Motion reduce the need for activity types?
6. Which permissions are requested during onboarding versus feature use?

### OTQ-015: What are the supported device and OS floors?

Status: Open

Decision deadline: Phase 1 exit

Current leaning: iOS 18 and watchOS 11 are provisional development floors. Actual support should follow capability, battery, adoption, and testing evidence.

Questions:

1. What is the oldest Watch that sustains required collection and battery life?
2. Does workout mirroring behave consistently across supported pairs?
3. Are any needed APIs available only in later systems?
4. Is an Apple Watch required, optional, or replaceable by a chest strap?
5. How many hardware combinations can continuous integration and device testing support honestly?
6. Should the Watch application be independently installable, independently runnable while disconnected, or only the latter?

### OTQ-016: What battery, thermal, and latency budgets are acceptable?

Status: Investigating in Phase 1

Decision deadline: Phase 1 exit

Questions:

1. What percentage of Watch battery may a one, three, and six hour session consume?
2. How much live latency is useful for a participant versus a facilitator?
3. Which display update rate avoids needless power use?
4. What batch and transfer cadence balances loss window and battery?
5. Should the app refuse to start below a battery threshold?
6. Which degraded modes are acceptable?

## Scientific and interpretive questions

### OTQ-017: What is personal baseline version 1?

Status: Open

Decision deadline: Phase 2 entry

Current leaning: Begin with transparent rolling median, median absolute deviation, within person percentile, and change from a pre session window. Context conditioning should grow only when data coverage supports it.

Questions:

1. What minimum history is required?
2. How are time of day, sleep, motion, exercise, illness, medication, caffeine, and alcohol handled?
3. What happens for a new participant with no history?
4. How are baseline versions compared over time?
5. How does the system avoid treating neurodivergent or trauma shaped physiology as deficit?

### OTQ-018: When should feedback appear?

Status: Open

Decision deadline: Phase 2 for default behavior, Phase 6 for experimental live modes

Current leaning: Private post session reflection is the default. Live feedback is an explicit intervention and research condition.

Questions:

1. Which feedback helps participants learn without producing performance anxiety?
2. Should the Watch show only recording and quality state during observation?
3. Can haptics guide breathing without being confused for passive measurement?
4. What may a facilitator see during a session?
5. How are measurement free periods represented and honored?
6. What participant reported outcomes define usefulness?

### OTQ-019: Which group metrics are scientifically defensible?

Status: Deferred to Phase 5 and Phase 6

Questions:

1. Which metrics distinguish individual state change, convergence, temporal synchrony, and shared response?
2. What windows and lag searches are justified for each source?
3. Which null models are mandatory?
4. How are respiration, motion, music, temperature, posture, meals, and facilitator cues controlled?
5. What uncertainty and effect size should the interface show?
6. What evidence would justify stronger language than synchrony?

### OTQ-020: How should physiology and participant report disagree?

Status: Deferred to Phase 6

Current leaning: Participant report is not training data to be silently overruled. Disagreement is a result that should remain visible and may invalidate an interpretation.

Questions:

1. Is participant report treated as context, outcome, correction, or ground truth?
2. How are dissociation, trained calm, excitement, illness, and medication represented?
3. Can a participant suppress an interpretation without deleting raw data?
4. What reflective prompts avoid claiming access to inner truth?

### OTQ-021: What is the boundary between wellness product and research instrument?

Status: Open

Decision deadline: Phase 4 entry

Questions:

1. Which features are available in ordinary product mode?
2. Which require research consent, ethics review, and protocol enrollment?
3. Are research exports available to participants outside a study?
4. Which claims could create medical device or clinical obligations?
5. How are experimental algorithms labeled in the interface and export?

## Group privacy and backend questions

### OTQ-022: What is the minimum safe group aggregation policy?

Status: Open

Decision deadline: Phase 4 entry

Current leaning: Ordinary facilitator views begin with at least five eligible participants. One on one and smaller group analysis requires unanimous, explicit, revocable consent and a separate interface.

Questions:

1. Is five sufficient under repeated or subgroup queries?
2. Can a facilitator infer one participant by comparing overlapping groups?
3. Are differential privacy or query budgets useful at pilot scale?
4. How are dropouts and missing data shown without identifying them?
5. Can participants veto a subgroup label?

### OTQ-023: What server retention and residency policy applies?

Status: Open

Decision deadline: Phase 4 entry

Questions:

1. Is raw event data deleted after feature computation or retained for reproducibility?
2. Can participants choose local only, derived only, or raw upload modes?
3. What is the default retention period for raw, normalized, derived, and audit data?
4. Must data remain in a participant's region?
5. How are backups expired and deletion verified?
6. Does a research study require a different retention contract?

### OTQ-024: What backend stack and operational boundary are justified?

Status: Deferred to Phase 4

Current leaning: Begin with HTTPS ingestion, PostgreSQL, encrypted object storage for large arrays, and a simple job queue. Add time series extensions only after measured query needs.

Questions:

1. Which language best shares schemas and validation fixtures with Swift?
2. Is PostgreSQL sufficient for expected pilot rates?
3. How are identity and physiological data separated operationally?
4. What tenant boundary exists for retreats, studies, and facilitators?
5. Which cloud provider and region satisfy policy without premature complexity?
6. What is the offline pilot fallback if cloud service is unavailable?

## Sensor and ecosystem questions

### OTQ-025: Which external heart sensor path should ship first?

Status: Deferred to Phase 3

Current leaning: Implement the standard BLE Heart Rate Service before adding Polar specific capabilities. Use Polar H10 as a reference for RR, ECG, and motion validation.

Questions:

1. Is generic RR behavior consistent enough across devices?
2. Does Polar's SDK license fit commercial and research distribution?
3. Is raw ECG needed in product mode or only validation mode?
4. How are sensor time, packet loss, buffer overflow, and firmware recorded?
5. Are straps participant owned, organizer supplied, or optional?

### OTQ-026: Which modality should follow cardiac sensing?

Status: Deferred to Phase 8

Current leaning: Respiration before EDA, voice, or EEG because it is both relevant and a major cardiac confound.

Questions:

1. Which respiration source is usable in real gatherings?
2. Does EDA add information beyond motion and cardiac response?
3. Can voice features be computed locally without retaining raw audio?
4. Which jurisdiction specific recording laws apply?
5. What concrete neurofeedback hypothesis justifies EEG or fNIRS?
6. Which hardware provides raw access, stable timestamps, tolerable artifacts, and acceptable licensing?

### OTQ-027: Does proximity improve the product enough to justify inference risk?

Status: Deferred to Phase 7

Current leaning: Use explicit event codes, schedules, rooms, and participant confirmation first. Test BLE zones later. UWB remains a selected peer experiment.

Questions:

1. Is room level context enough for useful group analysis?
2. Can radio observations expose an unwanted social graph?
3. How do participants inspect and reject inferred episodes?
4. What battery cost and false positive rate are acceptable?
5. Can exact ranging scale beyond a few selected peers?

### OTQ-028: When should Android or non Apple applications enter the monorepo?

Status: Deferred to Phase 9

Current leaning: Remain Apple only through acquisition and early scientific validation. Extract cross platform schemas when a second implementation exists.

Questions:

1. Does early Android support materially improve pilot recruitment?
2. Which wearable APIs offer comparable acquisition semantics?
3. Can group metrics compare sources with different cadence and quality?
4. Which shared protocol should move outside Swift, and when?

## Governance questions

### OTQ-029: Who approves scientific, privacy, and security decisions?

Status: Open

Decision deadline: Phase 4 entry

Questions:

1. Which decisions require founder approval?
2. When is independent scientific review mandatory?
3. Who can approve a new HealthKit type or sensor SDK?
4. Who can approve a new group metric or product claim?
5. What incident authority can stop collection or delete compromised data?
6. Which decisions and validation results are published openly?

### OTQ-030: What are the project's explicit stop conditions?

Status: Open

Decision deadline: Phase 1 exit for platform feasibility, Phase 6 for scientific feasibility

Questions:

1. What battery, sampling, or background behavior makes Apple Watch unsuitable for a use case?
2. What failure rate makes group alignment unreliable?
3. What evidence would reject a proposed synchrony metric?
4. What privacy or legal burden makes a modality unacceptable?
5. What participant harm or behavioral distortion stops live feedback?
6. What result would keep Coherence as a private personal tool rather than a group platform?

## Review cadence

Review this register at five moments:

1. Before starting a roadmap phase.
2. After every physical device experiment batch.
3. Before adding a HealthKit type, sensor, upload path, or group metric.
4. Before a pilot or App Store submission.
5. At phase closeout, with decision links and newly discovered questions.
