# Coherence mobile targets

This directory owns the native iPhone and Apple Watch application sources. The application targets remain intentionally thin. Shared domain, acquisition, persistence, synchronization, and feature logic belongs in `packages/CoherenceKit`.

The native Xcode project is not yet present. Xcode 26.6 and the required platform SDKs are installed, but Apple's license and first launch setup still require administrator approval. After activation, create a watchOS app with a companion iOS app and commit the resulting project here as `Coherence.xcodeproj`.

Use these target names and identifiers:

1. `CoherenceApp` is the iOS application. Its bundle identifier is `org.providencecollective.coherence`.
2. `CoherenceWatchApp` is the watchOS companion. Let Xcode derive its bundle identifier from the iOS target.
3. `CoherenceAppTests` contains iOS unit tests.
4. `CoherenceAppUITests` contains iOS interface tests.
5. `CoherenceWatchAppTests` contains watchOS unit tests.

Add the local package at `../../packages/CoherenceKit`. Link `CoherenceCore`, `CoherenceAcquisition`, `CoherenceData`, `CoherenceSync`, and `CoherenceFeatures` to the iOS target. Link the modules required by active recording to the watchOS target.

Use iOS 18 and watchOS 11 as the initial deployment floors. These are recommendations for the capability spike, not a permanent compatibility promise.

Enable HealthKit and HealthKit background delivery for the iOS target. Enable HealthKit and workout processing for the watchOS target. Use the checked in property lists and entitlement files as the source of truth.

The Watch target is provisionally configured as a companion that is not installed independently. This does not prevent an installed Watch application from buffering a measurement while its phone is temporarily unreachable. Independent installation and runtime disconnection are separate questions, and the final setting belongs to the Phase 1 capability evidence.
