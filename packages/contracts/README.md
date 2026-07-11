# Coherence contracts

Status: Boundary established, canonical representation not yet selected

This directory is the future language neutral authority for records that cross a process, device, platform, or service boundary. The current Swift models are useful provisional implementations. Swift synthesized `Codable` output is not a durable protocol specification.

Before the first durable Watch transfer is promoted beyond a capability spike, this package must define the initial contract subset for streams, samples, batches, acknowledgements, and session events. Before backend ingestion or Android synchronization, it must also include an independent non Swift validator.

The contract set must specify:

1. Tagged type discriminators and stable field identifiers.
2. Timestamp epoch, precision, timezone, and clock uncertainty semantics.
3. Identifier normalization and scope.
4. A constrained unit vocabulary, with UCUM preferred where it fits.
5. Collection ordering, numeric constraints, and unknown value behavior.
6. Canonical encoding, digest algorithm, digest scope, and exact hashed bytes.
7. Backward and forward compatibility rules.
8. Valid, invalid, corruption, and prior version fixtures.
9. A changelog and migration policy.

Swift, Kotlin, and service implementations must pass the same fixtures. Platform concepts such as HealthKit, Apple Watch, Health Connect, Wear OS, and WatchConnectivity belong in adapters or namespaced provenance, never in the canonical ontology.
