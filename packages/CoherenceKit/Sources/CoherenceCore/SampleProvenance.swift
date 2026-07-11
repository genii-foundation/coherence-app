import Foundation

public struct SampleProvenance: Codable, Equatable, Sendable {
  public let sourceBundleIdentifier: String?
  public let sourceVersion: String?
  public let deviceManufacturer: String?
  public let deviceModel: String?
  public let deviceHardwareVersion: String?
  public let deviceSoftwareVersion: String?
  public let originalSampleIdentifier: String?
  public let metadata: [String: String]

  public init(
    sourceBundleIdentifier: String? = nil,
    sourceVersion: String? = nil,
    deviceManufacturer: String? = nil,
    deviceModel: String? = nil,
    deviceHardwareVersion: String? = nil,
    deviceSoftwareVersion: String? = nil,
    originalSampleIdentifier: String? = nil,
    metadata: [String: String] = [:]
  ) {
    self.sourceBundleIdentifier = sourceBundleIdentifier
    self.sourceVersion = sourceVersion
    self.deviceManufacturer = deviceManufacturer
    self.deviceModel = deviceModel
    self.deviceHardwareVersion = deviceHardwareVersion
    self.deviceSoftwareVersion = deviceSoftwareVersion
    self.originalSampleIdentifier = originalSampleIdentifier
    self.metadata = metadata
  }
}
