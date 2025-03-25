// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription



let package = Package(
	name: "OTPFieldView",
	
	platforms: [
		.iOS(.v17),		//	17 for background .fill/stroke styling
		.macOS(.v14)	//	14 for background .fill/stroke styling
	],
	

	products: [
		.library(
			name: "OTPFieldView",
			targets: [
				"OTPFieldView"
			]),
	],
	targets: [

		.target(
			name: "OTPFieldView",
			dependencies: [],
			path: "./"
		)
	]
)
