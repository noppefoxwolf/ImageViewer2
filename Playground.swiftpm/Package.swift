// swift-tools-version: 5.8

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Playground",
    defaultLocalization: "en",
    platforms: [
        .iOS("16")
    ],
    products: [
        .iOSApplication(
            name: "Playground",
            targets: ["AppModule"],
            bundleIdentifier: "149EB157-7483-413F-B081-7B22B2C26FCC",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    
    dependencies: [
        .package(path: "../")
    ],
    
    targets: [
        .executableTarget(
            name: "AppModule",
            
            dependencies: [
                .product(
                    name: "PreviewKit",
                    package: "PreviewKit"
                )
            ],
            
            path: "."
        )
    ]
)
