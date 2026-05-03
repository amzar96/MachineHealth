// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MachineHealth",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "MachineHealth",
            path: "Sources/MachineHealth",
            linkerSettings: [.linkedFramework("IOKit")]
        )
    ]
)
