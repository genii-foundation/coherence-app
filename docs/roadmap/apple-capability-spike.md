# Apple capability spike

Status: Waiting for physical device signing and setup

This is the first implementation milestone. Its purpose is to replace platform assumptions with measurements from physical iPhones and Apple Watches.

## Required setup

1. Install a graphical Xcode version supported by the host operating system. The current macOS 27 beta host requires Xcode 27 beta for graphical development, and that authenticated Apple download is still pending.
2. Choose the GENII Foundation Apple developer team and place its identifier in ignored local configuration.
3. Sign, install, and launch both applications on a paired physical iPhone and Apple Watch.
4. Define a synthetic participant and an approved redacted export location.
5. Review this protocol and name the initial hardware matrix.
6. Use physical devices for every background, HealthKit, battery, and WatchConnectivity conclusion.

The native project, package links, simulator runtimes, fake composition, native tests, root validation, and continuous integration were completed in Phase 0B. They are prerequisites, not deliverables to rediscover during this spike.

## Simulator preparation available

Build Slice B now provides a simulator safe shell for the first authorization experiments:

1. The phone explains privacy and the minimum requested access before invoking Apple Health. Its first plan requests heart rate history read access only.
2. The Watch explains explicit measurement before preparing access. Its first plan requests live heart rate read access and workout write access, but does not start a workout or collect samples.
3. Platform neutral authorization state lives in `CoherenceAcquisition`. The actual HealthKit implementation remains inside the Apple adapter and application composition boundary.
4. Read authorization is always presented as noninspectable. A completed request says only that the request completed. HealthKit write status can be inspected for the workout type.
5. Debug fixtures cover `needs-request`, `request-recorded`, `write-denied`, `unavailable`, `needs-companion`, and `request-failure` through `COHERENCE_AUTHORIZATION_FIXTURE=<value>`.
6. The phone can preview and share a versioned diagnostic JSON snapshot. That snapshot explicitly excludes biometric values, participant identity, and persistent device identifiers.
7. Apple reporting that a request is unnecessary remains distinct from a locally recorded request. Request status inspection failures retain only a sanitized numeric diagnostic code.

Build Slice B.1 also provides simulator only lifecycle preparation:

1. `CoherenceCore` projects session state from an ordered event log and rejects invalid transitions, sequence gaps or regressions, session or authority changes, and conflicting duplicate identifiers. Exact duplicate events are idempotent.
2. Session interruption reasons are typed, and an interruption while recording projects to paused with resume and end available.
3. Debug composition accepts `COHERENCE_SESSION_FIXTURE=interactive` and exposes synthetic Watch controls for start, pause, resume, end, keep, discard, and restart.
4. The Watch states that the fixture captures no samples and uses no HealthKit. Its deterministic current and terminal event logs exist only in memory for the current application run, and replay failure cannot be mistaken for an absent session.
5. The phone states that it does not receive the Watch rehearsal state. No mirroring or WatchConnectivity behavior is implied.
6. Eleven shared CoherenceCore lifecycle tests, seven additional Watch lifecycle tests, and phone fixture independence and nonmirroring assertions cover this preparation.

Build Slice B.1 is not Build Slice C. This preparation starts no workout, reads no sensor, captures no sample, writes no HealthKit record, persists no event, and transfers no state. Phase 1 and Build Slice C remain Waiting.

This preparation is not physical experiment evidence. Root validation now includes ten phone tests, twelve Watch tests, and eleven shared CoherenceCore lifecycle tests on a temporary paired simulator set, and hosted validation remains a merge gate. Real HealthKit sheets, permission choices, query behavior, signing, background execution, sampling, battery, and connectivity remain untested until the required devices and authenticated Xcode setup are available.

## Capability questions

The spike must answer these questions with exported evidence.

### Authorization and history

1. Which requested HealthKit types are available on every selected device and OS combination?
2. Since HealthKit keeps individual read choices private, how should the app distinguish limited history, no matching samples, and an inaccessible source without claiming to know the participant's choice?
3. Can anchored imports resume without duplicates after process termination?
4. Are additions and deletions reconciled correctly?
5. Which `HKSourceRevision`, `HKDevice`, UUID, metadata, and algorithm version fields are present for each sample type?
6. What happens when the phone is locked while a background change notice arrives?

### Active Watch collection

1. Which legitimate workout configuration best fits an explicit Coherence measurement session?
2. What heart rate spacing appears during stillness, conversation, walking, meditation, and deliberate breathing?
3. How often are samples absent or delayed?
4. What source timestamps and arrival times are available?
5. Does collection continue when the wrist lowers, another Watch application opens, or the display sleeps?
6. What happens after pause, resume, save, discard, crash, and forced termination?
7. Does Low Power Mode change cadence or coverage?

### Live phone coordination

1. Can the Watch start workout mirroring and wake the phone reliably?
2. What is the median and worst observed latency for mirrored session data?
3. How does mirroring reconnect after temporary loss of range?
4. Can the phone control only the operations Apple intends it to control?
5. Which state transitions can arrive more than once or out of order?

### Durable Watch transfer

1. Which sealed batch size works reliably with queued WatchConnectivity transfer?
2. What happens when the phone is unreachable for one hour?
3. Does every acknowledged batch exist exactly once in the logical phone store after reconnection?
4. Are unacknowledged batches retained across Watch process termination and restart?
5. Can diagnostic exports prove transfer attempts, acknowledgements, retry timing, and duplicates?

### Clock alignment

1. What Watch and phone offset estimates result from repeated ping exchanges?
2. How stable is the offset over one, three, and six hours?
3. Can a wall clock adjustment be detected against monotonic time?
4. What uncertainty remains when a device is offline for a long interval?
5. At what uncertainty should group analysis refuse to align data?

### Battery and thermal behavior

1. What battery percentage does the Watch consume over one, three, and six hours?
2. What battery percentage does the phone consume with mirroring active, screen off, and screen on?
3. What are the effects of motion capture, batch frequency, interface updates, and transfer frequency?
4. Does either device show thermal pressure, suspension, or termination?
5. Which diagnostics remain available after an unexpected termination?

## Minimum device matrix

Test at least one oldest supported Watch, one recent standard Watch, and one current Ultra if accessible. Pair them with at least one oldest supported iPhone and one current iPhone. Record exact hardware, OS build, battery health, fit, wrist, power mode, connectivity, and test activity for every run.

Do not infer Ultra heart data resolution from its battery size. Public API access and measured behavior determine capability.

## Experiment protocol

Each test run should produce:

1. A unique run identifier and protocol version.
2. Device and application metadata.
3. Participant consent and synthetic participant identifier.
4. Start, pause, resume, end, save, and discard events.
5. Raw normalized samples and source provenance.
6. Wall and monotonic timing records.
7. Clock offset exchanges and uncertainty.
8. Connection state and transfer events.
9. Battery level and thermal state snapshots.
10. Expected disruptions with their exact timestamps.
11. A machine readable JSON export with biometric values, participant identity, and persistent device identifiers excluded from its diagnostic section, plus a concise human observation log.

Run these activities separately:

1. Quiet seated rest.
2. Ordinary conversation.
3. Paced breathing.
4. Meditation or Qigong.
5. Walking.
6. Meal period.
7. Phone locked and in range.
8. Phone disconnected and later restored.
9. Watch display sleeping.
10. App backgrounded on both devices.

## Acceptance criteria

The spike is complete when all of these statements have physical device evidence:

1. A participant can authorize the selected HealthKit types.
2. Historical import resumes from anchors without logical duplication.
3. Available source and device provenance is preserved.
4. A participant can explicitly start and end a Watch measurement session.
5. Live heart rate observations are recorded with measured cadence and gaps.
6. The phone receives live session state with measured latency.
7. The Watch buffers at least one hour without the phone.
8. Reconnection produces one logical copy of every acknowledged batch.
9. Clock offset and uncertainty are exported rather than hidden.
10. Battery use is measured over one, three, and six hours.
11. The participant can label, export, save, or discard the session.
12. The capability matrix names unsupported behavior and inconclusive results.
13. No group inference or medical claim is needed to pass.

## Explicit exclusions

This spike does not include account creation, backend upload, facilitator views, group metrics, chest straps, EEG, EDA, voice, emotion inference, proximity, UWB, or a composite coherence score.

## Deliverables

1. A physical device capability matrix.
2. Reproducible run exports with redacted synthetic identity.
3. A battery and sampling report.
4. A Watch and phone failure recovery report.
5. Updated architecture decisions based on observed behavior.
6. A go, revise, or stop decision for the Phase 2 individual data spine.
