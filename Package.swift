// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CyberScan3D",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "CyberScan3D",
            targets: ["CyberScan3D"]),
    ],
    dependencies: [
        // 未来可添加的依赖
    ],
    targets: [
        .target(
            name: "CyberScan3D",
            dependencies: []),
        .testTarget(
            name: "CyberScan3DTests",
            dependencies: ["CyberScan3D"]),
    ]
)