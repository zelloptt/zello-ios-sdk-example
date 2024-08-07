# Installation

This guide provides instructions for running the iOS example app, which showcases how to implement and use Zello’s SDK functionality on iOS devices. 

## Xcode Support

This example app was tested with Xcode 15.4 (15F31d). We’ve also confirmed it works with Xcode 16 Beta 4; despite warnings that may appear, the app will still successfully build and run on Xcode 16. 

## Install CocoaPods

The iOS example app is managed using [CocoaPods](https://cocoapods.org/). Typically, you can install CocoaPods by running `sudo gem install cocoapods` in your Mac’s terminal. However, we recommend following the [CocoaPods installation guide](https://guides.cocoapods.org/using/getting-started.html#getting-started) to ensure you have the latest instructions and can effectively troubleshoot any issues that may arise.

## Pod Install

Navigate to the project’s folder by running a cd command. Then, run pod install to install the app’s necessary pods. 

NOTE: If the pod install command fails due to version mismatches, run `pod install --repo-update`. This will update your local repositories and install any required dependencies. 

### Requirements

Zello’s SDK example app requires the following configurations:

- `IPHONEOS_DEPLOYMENT_TARGET` and `BUILD_LIBRARY_FOR_DISTRIBUTION`.

  - The example app’s deployment target is iOS 17. Please note that this differs from the core SDK, which operates on iOS 14+.

- `use_frameworks!`

## Open the Xcode workspace

Open the `ZelloSDKExampleApp.xcworkspace` project. This will launch the Zello SDK workspace, allowing you to build and run the project. 
