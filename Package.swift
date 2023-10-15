// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WorldTimeAPI",
  platforms: [.macOS(.v12)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "WorldTimeAPI",
      targets: ["WorldTimeAPI"])
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "WorldTimeAPI"),
    .executableTarget(name: "Example1", dependencies: ["WorldTimeAPI"], path: "Sources/Example1"),
    .testTarget(
      name: "WorldTimeAPITests",
      dependencies: ["WorldTimeAPI"]),
  ]
)
