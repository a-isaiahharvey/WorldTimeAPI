import Foundation

/// This enum defines the possible errors that can occur when using the WorldTimeAPI
public enum WorldTimeAPIError: Error {
  /// This case indicates that the payload contains an invalid key
  case InvalidKey(String)
  /// This case indicates that the payload is missing a required key
  case MissingKey(String)
}

/// This struct represents a client that can communicate with the WorldTimeAPI
public struct Client {
  /// This property stores the list of regions or ip information returned by the api
  public let regions: [Any]
  /// This property stores the base url of the api
  public let url: String

  /// This enum defines the possible endpoints of the api
  public enum Endpoint {
    /// This case represents the timezone endpoint
    case timezone
    /// This case represents the ip endpoint
    case ip
  }

  /// This initializer creates a client with a given endpoint and fetches the 
  /// regions or ip information from the api asynchronously
  public init(endpoint: Endpoint) async throws {
    var regions: [Any]

    switch endpoint {
    case .timezone:
      // Get the list of timezones from the api
      let url = URL(string: "https://worldtimeapi.org/api/timezone/")!
      let (data, _) = try await URLSession.shared.data(from: url)
      regions = try JSONSerialization.jsonObject(with: data) as! [Any]

    case .ip:
      // Get the ip information from the api
      let url = URL(string: "https://worldtimeapi.org/api/ip")!
      let (data, _) = try await URLSession.shared.data(from: url)
      regions = try JSONSerialization.jsonObject(with: data) as! [Any]
    }

    self.regions = regions
    self.url = "https://worldtimeapi.org/api/\(endpoint)"
  }

  /// This function takes a payload dictionary and returns a DateTimeJson 
  /// object asynchronously
  public func get(payload: [String: String]) async throws -> DateTimeJson {
    let keys = payload.keys
    var args = String()

    for item in keys where !["area", "location", "region"].contains(item) {
      throw WorldTimeAPIError.InvalidKey("Invalid key: \(item)")
    }

    if keys.contains("area") {
      args.append("/\(payload["area"]!)")
    } else {
      throw WorldTimeAPIError.MissingKey("Missing key: area")
    }

    if keys.contains("location") {
      args.append("/\(payload["location"]!)")
    }

    if keys.contains("location") && keys.contains("region") {
      args.append("/\(payload["region"]!)")
    } else if !keys.contains("location") && keys.contains("region") {
      throw WorldTimeAPIError.MissingKey("Missing key: region")
    }

    let (data, _) = try await URLSession.shared.data(from: URL(string: "\(self.url)\(args)")!)

    let decoder = JSONDecoder()

    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .customISO8601

    let response = try decoder.decode(DateTimeJson.self, from: data)

    return response
  }

}

extension Formatter {
  static let iso8601withFractionalSeconds: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()
  static let iso8601: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()
}

extension JSONDecoder.DateDecodingStrategy {
  static let customISO8601 = custom {
    let container = try $0.singleValueContainer()
    let string = try container.decode(String.self)
    if let date = Formatter.iso8601withFractionalSeconds.date(from: string)
      ?? Formatter.iso8601.date(from: string)
    {
      return date
    }
    throw DecodingError.dataCorruptedError(
      in: container, debugDescription: "Invalid date: \(string)")
  }
}
