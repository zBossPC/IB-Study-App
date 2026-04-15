// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IBStudy",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "IBStudy", targets: ["IBStudy"])
    ],
    targets: [
        .executableTarget(
            name: "IBStudy",
            path: "Sources/IBStudy",
            resources: [.process("Resources")]
        )
    ]
)
