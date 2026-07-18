# Application boundaries

Coherence is the product name across every platform. Application directories identify an implementation family, not a separate product brand.

Use this shape as platforms are added:

```text
apps/
  apple/
    ios/
    watchos/
  android/       # future
  web/           # future
```

Create a platform directory only when it contains an application or an approved capability spike. Within a platform, group source by executable target or operating system. Role specific surfaces belong beneath their platform, such as `apps/web/facilitator` or `apps/apple/macos/research-capture`.

Applications own composition roots, interface code, permissions, resources, and platform lifecycle. Reusable implementation logic belongs under `packages`. Canonical interchange contracts belong under `packages/contracts`. Applications must not import source from another application.

Do not introduce names such as Coherence Mobile, Coherence Desktop, or Coherence Cloud unless GENII Foundation intentionally creates a distinct user facing product. Form factor is an implementation detail, and implementation details are famously terrible at respecting marketing plans.
