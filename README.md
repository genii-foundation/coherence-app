# Coherence

Coherence is Providence's dedicated ecosystem for consented interpersonal biometric measurement and reflection. The first product is a native iPhone application with an Apple Watch companion. Together they will establish trustworthy acquisition, timing, provenance, quality, offline recovery, and personal baselines before the project attempts group synchrony analysis.

This repository is an Apple first monorepo. It is designed to add facilitator surfaces, research tools, backend services, and complementary applications without forcing them into either Apple target.

## Current foundation

The repository currently includes:

1. Thin SwiftUI source shells for the iPhone and Apple Watch applications.
2. HealthKit entitlement and permission source files for both applications.
3. A local Swift package with compile boundaries for domain models, acquisition, persistence, synchronization, and deterministic features.
4. Versioned `SensorSample`, `SampleBatch`, clock, provenance, quality, consent, and session contracts.
5. Shared package contract verification and a continuous integration entry point.
6. A thesis grounded [architecture overview](docs/architecture/overview.md).
7. A measured [Apple capability spike plan](docs/roadmap/apple-capability-spike.md).
8. A [unified phased roadmap](docs/roadmap/README.md) that controls what to build next.
9. A living [open technical questions register](docs/architecture/open-technical-questions.md).
10. A target by target [Xcode application roadmap](docs/roadmap/xcode-application-roadmap.md).
11. A durable [continuity brief synthesis](docs/research/continuity-brief-synthesis.md).

The native Xcode project is the one intentionally missing piece. Xcode 26.6 and the iOS and watchOS platform SDKs are now installed, but Apple's license and first launch setup still require administrator approval. The source and target specification are ready in [apps/coherence-mobile](apps/coherence-mobile/README.md).

## Repository shape

`apps/coherence-mobile` owns the iPhone and Apple Watch composition roots, interface code, resources, permissions, and entitlements.

`packages/CoherenceKit` owns portable, testable Swift modules shared by Apple applications.

`config/xcode` owns checked in build settings. Developer team identifiers stay in an ignored local file.

`docs` owns architecture, source research, scientific boundaries, and experimental protocols.

`scripts` owns the local health check and validation entry point.

Future applications belong under `apps`. Future backend services belong under `services`. Cross platform schemas and protocol fixtures should become their own package only when a second language actually consumes them.

## Validate the current foundation

Run:

```sh
./scripts/doctor.sh
./scripts/validate.sh
```

The validation script currently builds every shared Swift module and runs its contract verification. Once the native Xcode project is committed, the same script should also build the iPhone and watchOS targets and run their simulator tests. The Makefile provides matching convenience targets after Xcode activation.

## Product boundary

The first technical milestone is a single participant data spine. The first interpersonal milestone is a consented gathering session composed from multiple proven data spines. Neither milestone includes a universal coherence score, physiological ranking, EEG, emotion recognition, invisible proximity tracking, or medical claims.

The governing rule is simple: preserve measurements and uncertainty first, then earn the right to interpret them.
