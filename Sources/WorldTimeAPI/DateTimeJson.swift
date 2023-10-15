import Foundation

/// Any valid JSON response form acquiring a DateTime from timezone endpoint
public struct DateTimeJson: Codable {
  public let abbreviation: String
  public let clientIp: String
  public let datetime: Date
  public let dayOfWeek: Int64
  public let dayOfYear: Int64
  public let dst: Bool
  public let dstFrom: Date?
  public let dstOffset: Int64
  public let dstUntil: Date?
  public let rawOffset: Int64
  public let timezone: String
  public let unixtime: Int64
  public let utcDatetime: Date
  public let utcOffset: String
  public let weekNumber: Int64

  /// Returns the abbreviation of the timezone
  public func keyList() -> [String] {
    [
      "abbreviation",
      "client_ip",
      "datetime",
      "day_of_week",
      "day_of_year",
      "dst",
      "dst_from",
      "dst_offset",
      "dst_until",
      "raw_offset",
      "timezone",
      "unixtime",
      "utc_datetime",
      "utc_offset",
      "week_number",
    ]
  }
}
