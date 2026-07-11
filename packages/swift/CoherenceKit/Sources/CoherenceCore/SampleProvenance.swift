import Foundation

public struct SourceIdentity: Codable, Equatable, Sendable {
  public let namespace: String
  public let identifier: String

  public init(namespace: String, identifier: String) {
    self.namespace = namespace
    self.identifier = identifier
  }
}

public struct SampleProvenance: Codable, Equatable, Sendable {
  public let source: SourceIdentity?
  public let sourceVersion: String?
  public let deviceManufacturer: String?
  public let deviceModel: String?
  public let deviceHardwareVersion: String?
  public let deviceSoftwareVersion: String?
  public let originalSampleIdentifier: String?
  public let metadata: [String: String]

  public init(
    source: SourceIdentity? = nil,
    sourceVersion: String? = nil,
    deviceManufacturer: String? = nil,
    deviceModel: String? = nil,
    deviceHardwareVersion: String? = nil,
    deviceSoftwareVersion: String? = nil,
    originalSampleIdentifier: String? = nil,
    metadata: [String: String] = [:]
  ) {
    self.source = source
    self.sourceVersion = sourceVersion
    self.deviceManufacturer = deviceManufacturer
    self.deviceModel = deviceModel
    self.deviceHardwareVersion = deviceHardwareVersion
    self.deviceSoftwareVersion = deviceSoftwareVersion
    self.originalSampleIdentifier = originalSampleIdentifier
    self.metadata = metadata
  }
}
