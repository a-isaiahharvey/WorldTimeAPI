import Foundation

public enum WorldTimeAPIError: Error {
  case InvalidKey(String)
  case MissingKey(String)
}

public struct Client {
  public let regions: [Any]
  public let url: String

  public enum Endpoint {
    case timezone
    case ip
  }

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
