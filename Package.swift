// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "OctoSeer",
    products: [
        .library(name: "OctoSeer", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.6.2")
    ],
    targets: [
        .target(name: "App",
                dependencies: ["FluentSQLite", "Vapor", "JWT", "RxSwift", "RxRelay", "Yams", "Swinject"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

