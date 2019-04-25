// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Octoseer",
    products: [
        .library(name: "Octoseer", targets: ["Octoseer"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.6.2")
    ],
    targets: [
        .target(name: "Octoseer",
                dependencies: ["FluentSQLite", "Vapor", "JWT", "Yams", "Swinject"]),
        .target(name: "Run", dependencies: ["Octoseer"]),
        .testTarget(name: "OctoseerTests", dependencies: ["Octoseer"])
    ]
)

