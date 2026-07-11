# Monorepo platform and contract boundaries

Status: Accepted

Date: 2026-07-10

Owners: Providence engineering

Related questions: OTQ-004, OTQ-028, OTQ-031

Related roadmap phase: Phase 0A and all later phases

## Decision

Coherence is one product and one ecosystem. Platform names describe implementations, not product variants.

The repository uses these durable boundaries:

1. `apps/<platform>` contains executable applications and platform composition roots.
2. `packages/contracts` contains canonical language neutral schemas, semantic vocabularies, conformance fixtures, compatibility rules, and migrations.
3. `packages/<language>` contains implementations, generated bindings, ports, and reusable language specific logic.
4. `services/<service>` contains independently deployable backend systems.
5. `config/<platform-or-tool>` contains checked in configuration that is shared across targets.

Apple is the first implementation and capability proving ground. It is not the identity of the repository or the canonical ontology. HealthKit, Apple Watch, WatchConnectivity, Google Health Connect, Wear OS, and other vendor concepts remain in platform adapters or namespaced provenance.

Canonical contracts become authoritative before the first backend API or Android synchronization implementation. Durable Apple transfer also requires an accepted initial encoding and fixture subset because application versions can differ even when both endpoints use Swift.

## Context

The first repository shape grouped the iPhone and Watch applications under `apps/coherence-mobile` and placed shared Swift code directly under `packages/CoherenceKit`. That naming made the Apple implementation look like the product boundary and left no explicit authority for future Kotlin, service, or wire contracts.

Coherence is expected to grow across phones, wearables, browsers, research tools, facilitator surfaces, and services. The repository needs stable ownership boundaries before those implementations exist, without generating empty scaffolding for imaginary products.

## Evidence

The current roadmap already requires device independent sample identity, provenance, timing, consent, deletion, and feature lineage. Swift synthesized `Codable` does not by itself define canonical timestamps, enum discriminators, collection ordering, unknown value behavior, or digest bytes for other languages.

## Options considered

1. Keep `apps/coherence-mobile` and add Android beneath it. This confuses the Apple target family with a general mobile product and has no natural home for Watch, web, or desktop surfaces.
2. Organize everything by feature. This encourages applications, platform adapters, contracts, and services to import each other's internals.
3. Organize applications by platform, packages by authority and language, and services by deployment boundary. This keeps product identity stable while allowing implementation families to evolve independently.

## Rationale

The selected structure makes dependency direction visible in paths. It lets Apple work move quickly now without encoding Apple assumptions into records that Android and services must later imitate. It also delays technology choices inside `packages/contracts` until contract questions have evidence.

## Consequences

1. The Apple source root is `apps/apple`, with initial targets under `ios` and `watchos`.
2. The Swift package root is `packages/swift/CoherenceKit`.
3. Android will use `apps/android` and normally `packages/kotlin` when implementation begins.
4. Web applications will use `apps/web`, with role specific surfaces below it.
5. Swift models remain provisional until accepted canonical contracts and fixtures exist.
6. Contract work begins before backend or Android interoperability, not after incompatibilities arrive.
7. Empty future application and language directories are not committed merely to reserve names.

## Verification

1. Repository validation uses the platform and language specific paths.
2. No active product or directory is named Coherence Mobile.
3. Core domain types use vendor neutral names.
4. Pull requests that introduce network or cross platform records include canonical schema and fixture changes.
5. Every implementation passes the same contract conformance suite before interoperability ships.

## Revisit conditions

Revisit the taxonomy if one product receives an intentionally separate brand, if a security boundary requires a separate repository, or if measured ownership and release cadence make the monorepo harmful. Do not reopen it merely because one build tool prefers a different folder name.
