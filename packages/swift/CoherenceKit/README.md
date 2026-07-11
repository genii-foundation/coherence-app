# CoherenceKit

CoherenceKit contains the Swift implementation used by Coherence applications on Apple platforms. Its modules provide domain models, acquisition ports, local persistence ports, delivery coordination, and deterministic features.

These types are provisional implementation models until the corresponding records are accepted under `packages/contracts`. Apple framework adapters may implement these ports, but Apple framework types and vendor specific names must not enter `CoherenceCore`.

Dependency direction is:

1. `CoherenceCore` depends only on Foundation.
2. Acquisition, Data, Sync, and Features depend on Core.
3. Apple applications compose these modules with platform adapters.
4. Canonical interchange encoders and decoders conform to `packages/contracts` once that contract gate closes.

Backend services and future Android applications must not import or translate arbitrary Swift `Codable` output. They consume the canonical schemas and fixtures.
