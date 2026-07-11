# Continuity brief synthesis

Source: Founder supplied continuity brief, July 10, 2026

This document preserves the actionable content of the supplied Unified Biometric Consolidation App continuity brief inside the repository. It is a synthesis, not a replacement for current platform documentation, scientific validation, legal review, or physical device experiments.

## Core direction

Build a native iPhone and Apple Watch system that consolidates authorized biometric data into a coherent, timestamped, provenance rich, offline capable personal record. Build group analysis on top of that record only after acquisition, synchronization, consent, and quality are trustworthy.

Do not begin with one composite coherence score.

## Product modes

1. Personal history imports authorized HealthKit data and builds context aware personal baselines.
2. Passive retreat mode uses the samples that Apple devices and other sources normally save, with variable density.
3. Explicit measurement mode uses a user started Watch health or workout session for denser live heart rate.
4. External sensor mode uses each participant's iPhone as the local gateway for a chest strap or later device.
5. Group mode enrolls participants in an event, buffers locally, uploads when possible, and shows consent eligible aggregates.

## Scientific distinctions

Keep these constructs separate:

1. Individual state change is movement relative to one person's baseline.
2. Group convergence is a reduction in differences among participants.
3. Temporal synchrony is aligned change over time.
4. Shared response is similar reaction to a common stimulus.

Shared breathing instructions, movement, music, temperature, posture, meals, schedule, device timing, and artifacts can create apparent synchrony. None of the four constructs proves relationship quality, presence, relaxation, emotional valence, or interpersonal causation.

## Apple realities carried forward

1. Passive Watch heart rate is not a guaranteed continuous stream.
2. An explicit workout session can provide denser heart rate and supported background execution, but it requires a legitimate user visible lifecycle and battery testing.
3. Heart rate values do not provide qualified beat to beat HRV.
4. Apple generated HealthKit HRV SDNN is useful as sparse longitudinal context.
5. Apple Watch does not expose a general continuous raw PPG or ECG feed to third party applications.
6. HealthKit background delivery reports that changes exist. It is not a low latency sample stream.
7. HealthKit provenance is evidence, not cryptographic authenticity.
8. Bluetooth background execution requires restoration, reconnection, buffering, and acceptance of system suspension.
9. UWB is a later experiment, not the first group context backbone.

These statements must be checked against current official Apple documentation and measured on selected hardware. The current architecture overview records that verification.

## Initial vertical slice

The first complete slice is single participant even though the long term product is interpersonal.

It includes:

1. Native SwiftUI phone and Watch applications.
2. Clear HealthKit authorization.
3. Historical heart rate, HRV SDNN, resting heart rate, workout, activity, sleep, respiratory, and selected context imports.
4. Available source and device provenance.
5. An explicit Watch measurement session with live heart rate.
6. Protected local storage on both devices.
7. Reliable Watch and phone reconciliation.
8. Offline buffering and idempotent delivery.
9. Manual session labels.
10. A private personal timeline.
11. JSON or CSV export.
12. Gap, duplicate, value, coverage, clock, battery, and sampling diagnostics.

It excludes EEG, emotion recognition, UWB clustering, and a composite coherence score.

## Architectural modules

The brief proposes these conceptual modules:

1. Sensor adapters normalize HealthKit history, Watch heart rate, Watch motion, BLE heart sensors, and manual annotations.
2. A session coordinator owns lifecycle, active adapters, consent, buffering, clock state, upload state, and completeness.
3. A local append store preserves raw or minimally processed samples and provenance.
4. A sync engine provides offline retry, stable identifiers, resumable batches, conflict safe annotations, and deletion propagation.
5. A feature engine computes deterministic, inspectable, versioned features.
6. A group aggregation service later enforces consent, personal normalization, minimum group policy, coverage, and uncertainty.

The repository maps these concepts into `CoherenceCore`, `CoherenceAcquisition`, `CoherenceData`, `CoherenceSync`, and `CoherenceFeatures`.

## Data model themes

Preserve participant pseudonyms, devices, consent receipts, events, activities, participant measurement sessions, sensor streams, immutable batches, annotations, clock estimates, features, personal baselines, group episodes, and group metrics as separate concepts.

Important refinements made in this repository are:

1. Structured provenance replaces a single provenance score.
2. Nominal sample rate is optional because many sources are irregular.
3. Consent includes capture intent, acquisition source, session, retention, representation, research, and model scope.
4. Clock estimates are versioned records for any reference device, not one mutable server offset.
5. Physical delivery is at least once. Stable identifiers and required content digests provide one logical record.
6. Deletion is scoped and must invalidate derived results.
7. Session lifecycle is represented by immutable events in addition to a current projection.

## Group analysis order

Begin with mean normalized state change, dispersion, directional agreement, pairwise association, subgroup structure, coverage, and null comparisons. Add phase locking, recurrence, mutual information, network synchrony, or latent models only when source cadence and validation support them.

Every result includes contributor count, capture intent, acquisition source class, quality threshold, coverage, clock uncertainty, statistical uncertainty, algorithm version, and exploratory or validated status.

## Sensor order

1. Apple Watch for convenience, live heart rate, motion, and longitudinal HealthKit context.
2. Generic BLE Heart Rate Service for RR intervals.
3. Polar H10 as the first reference chest strap and possible validation ECG source.
4. Respiration because it is a major cardiac synchrony confound.
5. EDA, voice, proximity, and neural sensors only through separate research and consent work.

## Privacy position

1. Participants see their own individual results.
2. Facilitators and peers see eligible aggregates by default.
3. Identifiable physiology requires separate, revocable consent.
4. Ordinary aggregate views begin with a configurable minimum of five.
5. One on one and smaller groups require unanimous explicit consent.
6. No leaderboards, advertising use, hidden behavioral marketing, or physiological eligibility decisions.
7. Account identity remains separate from physiological records.
8. Participants can inspect, pause, leave, revoke, export, exclude, and delete.

## Delivery sequence

1. Native project bootstrap.
2. Apple capability spike.
3. Local single participant data spine.
4. External heart sensor and qualified HRV.
5. Consent governed account, event, and backend foundation.
6. Delayed group aggregation.
7. Scientific validation.
8. Proximity experiments.
9. Additional modalities.

The [unified roadmap](../roadmap/README.md) turns this sequence into implementation entry and exit criteria.
