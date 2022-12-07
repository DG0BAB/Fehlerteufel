// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Name of this Package
let packageName = "Fehlerteufel"

// Package creation
let package = Package(name: packageName)

// Products define the executables and libraries produced by a package, and make them visible to other packages.
package.defaultLocalization = "en"
package.products = [.library(name: packageName, targets: [packageName])]
package.platforms = [.iOS(.v13), .macOS(.v10_15)]
package.dependencies = [
	.package(url: "https://github.com/DG0BAB/Clause.git", .branch("master")),
]
package.targets = [
	.target(name: packageName, dependencies: ["Clause"], path: "Sources", resources: [Resource.process("Resources")]),
	.testTarget(name: "\(packageName)Tests", dependencies: [Target.Dependency(stringLiteral: packageName)], path: "Tests"),
]
