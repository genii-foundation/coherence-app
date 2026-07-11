# Service boundaries

Coherence requires no backend for the first local measurement phases. Deployable services will live here only when a roadmap phase justifies them.

Likely future boundaries include authenticated ingestion, consent policy, group analysis, and participant export and deletion. Each service must consume canonical records from `packages/contracts`, enforce least privilege, and own its deployment and operational configuration. Services must not import Apple application source or treat the Swift package as a network specification.

Do not create one service per noun. Begin with the smallest deployable system that preserves security boundaries, then split only when ownership, scaling, data residency, or failure isolation provides evidence. Microservices are not a spiritual practice.
