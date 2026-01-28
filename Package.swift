// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "PortScanner",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "PortScanner", targets: ["PortScanner"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "PortScanner",
            dependencies: [],
            path: "."
        )
    ]
)
