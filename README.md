# Coherence

Coherence is Providence's dedicated ecosystem for consented interpersonal biometric measurement and reflection. Its first implementation is a native iPhone application with an Apple Watch companion. Together they will establish trustworthy acquisition, timing, provenance, quality, offline recovery, and personal baselines before the project attempts group synchrony analysis.

This is a cross platform monorepo with Apple as its first implementation and empirical proving ground. The product remains Coherence on every platform. Apple, Android, web, and future platform names identify implementation families, not separate product brands.

## Current foundation

The repository currently includes:

1. Native SwiftUI application targets for iPhone and Apple Watch, plus phone unit, phone interface, and Watch unit test targets.
2. A versioned XcodeGen specification and committed generated Xcode project with shared `Coherence` and `CoherenceWatch` schemes.
3. HealthKit entitlement and permission source files for both applications.
4. A local Swift package with compile boundaries for provisional domain models, acquisition, persistence, synchronization, and deterministic features.
5. Versioned `SensorSample`, `SampleBatch`, clock, provenance, quality, consent, and session models, plus an explicit home for canonical language neutral contracts.
6. Deterministic synthetic sensor composition for simulator tests, clearly labeled as synthetic provenance.
7. Shared package and native application validation in continuous integration.
8. A thesis grounded [architecture overview](docs/architecture/overview.md).
9. A measured [Apple capability spike plan](docs/roadmap/apple-capability-spike.md).
10. A [unified phased roadmap](docs/roadmap/README.md) that controls what to build next.
11. A living [open technical questions register](docs/architecture/open-technical-questions.md).
12. A target by target [Xcode application roadmap](docs/roadmap/xcode-application-roadmap.md).
13. A durable [continuity brief synthesis](docs/research/continuity-brief-synthesis.md).
14. An accepted [monorepo platform boundary decision](docs/architecture/decisions/0001-monorepo-platform-boundaries.md).

The native Apple bootstrap is complete. `apps/apple/project.yml` is the source of truth for `apps/apple/Coherence.xcodeproj`, and XcodeGen 2.45.4 reproduces the committed project. See [apps/apple](apps/apple/README.md) for target details and local toolchain guidance.

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
./scripts/generate-apple-project.sh
./scripts/validate.sh
```

The generation command requires XcodeGen 2.45.4 and rewrites the committed Xcode project from its versioned specification. Root validation builds every shared Swift module, verifies the core contracts, builds the iPhone application with its embedded Watch companion, builds the Watch application independently, and runs phone and Watch simulator smoke tests. `make project` and `make validate` provide matching convenience targets.

On the current macOS 27 beta host, Xcode 26.6 command line builds work, but its graphical application is not a supported pairing. Use Xcode 27 beta for local graphical development once it has been downloaded through an authenticated Apple developer account. Continuous integration remains pinned to Xcode 26.6 on a supported macOS 26 runner.

## Product boundary

The first technical milestone is a single participant data spine. The first interpersonal milestone is a consented gathering session composed from multiple proven data spines. Neither milestone includes a universal coherence score, physiological ranking, EEG, emotion recognition, invisible proximity tracking, or medical claims.

The governing rule is simple: preserve measurements and uncertainty first, then earn the right to interpret them.
