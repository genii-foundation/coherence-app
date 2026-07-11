# Package boundaries

Packages are grouped by authority and implementation language.

```text
packages/
  contracts/          # canonical schemas, vocabularies, fixtures, compatibility
  swift/              # Swift implementations and platform ports
  kotlin/             # future Android implementations
  typescript/         # future web or service implementations, if justified
```

`packages/contracts` becomes the language neutral authority before durable protocols are frozen. Language directories contain implementations, generated bindings, concurrency layers, and platform adapters. No Swift, Kotlin, or TypeScript model becomes canonical merely because it was written first.

Packages may depend on canonical contracts and on packages in their own language when the dependency graph remains acyclic. They must not depend on application source. Services and applications share schemas and conformance fixtures, not each other's internal models.
