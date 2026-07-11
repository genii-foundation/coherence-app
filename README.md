# Coherence

Coherence is Providence's dedicated ecosystem for consented interpersonal biometric measurement and reflection. Its first implementation is a native iPhone application with an Apple Watch companion. Together they will establish trustworthy acquisition, timing, provenance, quality, offline recovery, and personal baselines before the project attempts group synchrony analysis.

This is a cross platform monorepo with Apple as its first implementation and empirical proving ground. The product remains Coherence on every platform. Apple, Android, web, and future platform names identify implementation families, not separate product brands.

## Current foundation

The repository currently includes:

1. Thin SwiftUI source shells for the iPhone and Apple Watch applications.
2. HealthKit entitlement and permission source files for both applications.
3. A local Swift package with compile boundaries for provisional domain models, acquisition, persistence, synchronization, and deterministic features.
4. Versioned `SensorSample`, `SampleBatch`, clock, provenance, quality, consent, and session models, plus an explicit home for canonical language neutral contracts.
5. Shared package contract verification and a continuous integration entry point.
6. A thesis grounded [architecture overview](docs/architecture/overview.md).
7. A measured [Apple capability spike plan](docs/roadmap/apple-capability-spike.md).
8. A [unified phased roadmap](docs/roadmap/README.md) that controls what to build next.
9. A living [open technical questions register](docs/architecture/open-technical-questions.md).
10. A target by target [Xcode application roadmap](docs/roadmap/xcode-application-roadmap.md).
11. A durable [continuity brief synthesis](docs/research/continuity-brief-synthesis.md).
12. An accepted [monorepo platform boundary decision](docs/architecture/decisions/0001-monorepo-platform-boundaries.md).

The native Xcode project is the one intentionally missing piece. Xcode 26.6 and the iOS and watchOS platform SDKs are now installed, but Apple's license and first launch setup still require administrator approval. The source and target specification are ready in [apps/apple](apps/apple/README.md).

## Repository shape

```text
apps/                       executable applications grouped by platform
  apple/                    iOS, watchOS, and future Apple targets
packages/
  contracts/                canonical schemas and conformance fixtures
  swift/CoherenceKit/       reusable Swift implementation
services/                   future deployable backend systems
config/apple/xcode/         shared Apple build settings
docs/                       architecture, research, and roadmaps
scripts/                    repository health and validation
```

Future Android applications belong under `apps/android`, with reusable Kotlin code under `packages/kotlin`. Future web surfaces belong under `apps/web`. Role names sit beneath a platform, such as `apps/web/facilitator`, rather than replacing the platform boundary.

Applications may depend on language packages. Language packages may implement canonical contracts. Services and clients share schemas and conformance fixtures, never application source. Vendor APIs stay in platform adapters.

The current Swift models are provisional. `packages/contracts` becomes authoritative before a backend API or Android synchronization work begins. Its first encoding and fixture subset is also required before durable Apple transfer leaves the capability spike. This prevents Swift serialization details from becoming a treaty that every later platform signs under duress.

See [application boundaries](apps/README.md), [package boundaries](packages/README.md), and [service boundaries](services/README.md) for the ownership rules.

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
