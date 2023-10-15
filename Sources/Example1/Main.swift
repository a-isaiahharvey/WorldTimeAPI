import WorldTimeAPI

@main
struct Main {
  static func main() async {
    do {
      let client = try await Client(endpoint: .timezone)
      let requests = ["area": "America", "location": "New_York"]

      // Returns DateTimeJson
      let response = try await client.get(payload: requests)

      print(response)

    } catch {
      print(error.localizedDescription)
    }

  }
}
