// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DurableCostMath",
    products: [
        .library(name: "DurableCostMath", targets: ["DurableCostMath"])
    ],
    targets: [
        .target(name: "DurableCostMath")
    ]
)
