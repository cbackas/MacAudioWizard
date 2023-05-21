// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MacAudioWizard",
    products: [
        .executable(name: "MacAudioWizard", targets: ["MacAudioWizard"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "MacAudioWizard",
            dependencies: ["SwiftyBeaver"],
            path: "Sources"),
    ]
)
