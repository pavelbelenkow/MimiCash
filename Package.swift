// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MimiCash",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.5.2")
    ],
    targets: [
        .target(
            name: "MimiCash",
            dependencies: ["Lottie"]
        )
    ]
) 