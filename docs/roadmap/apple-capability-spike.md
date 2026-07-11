# Apple capability spike

Status: Ready after Xcode activation and native project bootstrap

This is the first implementation milestone. Its purpose is to replace platform assumptions with measurements from physical iPhones and Apple Watches.

## Required setup

1. Accept Apple's license for the installed Xcode 26.6 application.
2. Complete Xcode first launch setup and verify the installed iOS and watchOS platforms.
3. Create the native iPhone application with a companion Watch application in `apps/coherence-mobile`.
4. Attach the checked in source directories, property lists, entitlements, build settings, and local `CoherenceKit` package.
5. Choose the Providence Apple developer team and place its identifier in ignored local configuration.
6. Add iOS, watchOS, and package build checks to `scripts/validate.sh` and continuous integration.
7. Use physical devices for every background, HealthKit, battery, and WatchConnectivity conclusion.

## Capability questions

The spike must answer these questions with exported evidence.

### Authorization and history

1. Which requested HealthKit types are available on every selected device and OS combination?
2. How does limited historical authorization appear to the app?
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
11. A machine readable JSON export and a concise human observation log.

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

1. A committed native Xcode project and target tests.
2. A physical device capability matrix.
3. Reproducible run exports with redacted synthetic identity.
4. A battery and sampling report.
5. A Watch and phone failure recovery report.
6. Updated architecture decisions based on observed behavior.
7. A go, revise, or stop decision for the Phase 1 individual data spine.
