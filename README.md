# World Time Wrapper

This is a simple wrapper for the [World Time API](http://worldtimeapi.org). This
crate is based on the
[WorldTimeAPI wrapper](https://github.com/Dulatr/WorldTimeAPI) by Dulatr.

## Installation

You can integrate AnsiStyle into your project using Swift Package Manager (SPM).
Simply add it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/martial-plains/worldtimeapi-rs.git", branch: "main")
]
```

## Example

```swift
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
```
