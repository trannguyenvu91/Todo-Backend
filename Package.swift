// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Todo-Backend",
    dependencies: [
        .package(url: "https://github.com/SwiftORM/Postgres-StORM.git", "3.0.0"..<"4.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-XML.git", "3.0.0"..<"4.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", "3.0.0"..<"4.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Turnstile-MySQL.git", "3.0.0"..<"4.0.0")
    ],
    targets: [
        .target(name: "Todo-Backend", dependencies: ["PostgresStORM", "PerfectXML", "PerfectHTTPServer", "PerfectTurnstileMySQL"])
    ]
)
