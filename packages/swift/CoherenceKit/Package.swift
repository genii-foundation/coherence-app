// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "CoherenceKit",
  platforms: [
    .iOS(.v18),
    .watchOS(.v11),
    .macOS(.v15),
  ],
  products: [
    .library(name: "CoherenceCore", targets: ["CoherenceCore"]),
    .library(name: "CoherenceAcquisition", targets: ["CoherenceAcquisition"]),
    .library(name: "CoherenceData", targets: ["CoherenceData"]),
    .library(name: "CoherenceSync", targets: ["CoherenceSync"]),
    .library(name: "CoherenceFeatures", targets: ["CoherenceFeatures"]),
    .executable(
      name: "CoherenceCoreVerification",
      targets: ["CoherenceCoreVerification"]
    ),
  ],
  targets: [
    .target(name: "CoherenceCore"),
    .target(
      name: "CoherenceAcquisition",
      dependencies: ["CoherenceCore"]
    ),
    .target(
      name: "CoherenceData",
      dependencies: ["CoherenceCore"]
    ),
    .target(
      name: "CoherenceSync",
      dependencies: ["CoherenceCore"]
    ),
    .target(
      name: "CoherenceFeatures",
      dependencies: ["CoherenceCore"]
    ),
    .executableTarget(
      name: "CoherenceCoreVerification",
      dependencies: ["CoherenceCore"]
    ),
    .testTarget(
      name: "CoherenceCoreTests",
      dependencies: ["CoherenceCore"]
    ),
  ]
)
