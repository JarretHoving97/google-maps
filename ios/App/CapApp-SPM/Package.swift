// swift-tools-version: 5.9
import PackageDescription

// DO NOT MODIFY THIS FILE - managed by Capacitor CLI commands
let package = Package(
    name: "CapApp-SPM",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CapApp-SPM",
            targets: ["CapApp-SPM"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", exact: "7.4.4"),
        .package(name: "CapacitorCommunityGenericOauth2", path: "../../../node_modules/@capacitor-community/generic-oauth2"),
        .package(name: "CapacitorCommunityGoogleMaps", path: "../../../node_modules/@capacitor-community/google-maps"),
        .package(name: "CapacitorCommunityInAppReview", path: "../../../node_modules/@capacitor-community/in-app-review"),
        .package(name: "CapacitorCommunityPrivacyScreen", path: "../../../node_modules/@capacitor-community/privacy-screen"),
        .package(name: "CapacitorCommunitySafeArea", path: "../../../node_modules/@capacitor-community/safe-area"),
        .package(name: "CapacitorApp", path: "../../../node_modules/@capacitor/app"),
        .package(name: "CapacitorCamera", path: "../../../node_modules/@capacitor/camera"),
        .package(name: "CapacitorDevice", path: "../../../node_modules/@capacitor/device"),
        .package(name: "CapacitorGeolocation", path: "../../../node_modules/@capacitor/geolocation"),
        .package(name: "CapacitorKeyboard", path: "../../../node_modules/@capacitor/keyboard"),
        .package(name: "CapacitorPreferences", path: "../../../node_modules/@capacitor/preferences"),
        .package(name: "CapacitorPushNotifications", path: "../../../node_modules/@capacitor/push-notifications"),
        .package(name: "CapacitorShare", path: "../../../node_modules/@capacitor/share"),
        .package(name: "CapacitorSplashScreen", path: "../../../node_modules/@capacitor/splash-screen"),
        .package(name: "CapacitorNativeSettings", path: "../../../node_modules/capacitor-native-settings"),
        .package(name: "CapacitorSecureStoragePlugin", path: "../../../node_modules/capacitor-secure-storage-plugin")
    ],
    targets: [
        .target(
            name: "CapApp-SPM",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "CapacitorCommunityGenericOauth2", package: "CapacitorCommunityGenericOauth2"),
                .product(name: "CapacitorCommunityGoogleMaps", package: "CapacitorCommunityGoogleMaps"),
                .product(name: "CapacitorCommunityInAppReview", package: "CapacitorCommunityInAppReview"),
                .product(name: "CapacitorCommunityPrivacyScreen", package: "CapacitorCommunityPrivacyScreen"),
                .product(name: "CapacitorCommunitySafeArea", package: "CapacitorCommunitySafeArea"),
                .product(name: "CapacitorApp", package: "CapacitorApp"),
                .product(name: "CapacitorCamera", package: "CapacitorCamera"),
                .product(name: "CapacitorDevice", package: "CapacitorDevice"),
                .product(name: "CapacitorGeolocation", package: "CapacitorGeolocation"),
                .product(name: "CapacitorKeyboard", package: "CapacitorKeyboard"),
                .product(name: "CapacitorPreferences", package: "CapacitorPreferences"),
                .product(name: "CapacitorPushNotifications", package: "CapacitorPushNotifications"),
                .product(name: "CapacitorShare", package: "CapacitorShare"),
                .product(name: "CapacitorSplashScreen", package: "CapacitorSplashScreen"),
                .product(name: "CapacitorNativeSettings", package: "CapacitorNativeSettings"),
                .product(name: "CapacitorSecureStoragePlugin", package: "CapacitorSecureStoragePlugin")
            ]
        )
    ]
)
