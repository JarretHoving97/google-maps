import Capacitor

enum HourCycle: String {
    case h11
    case h12
    case h23
    case h24
}

@objc(ExtendedDeviceSettingsPlugin)
public class ExtendedDeviceSettingsPlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "ExtendedDeviceSettings"

    public let jsName = "ExtendedDeviceSettings"

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "getHourCycle", returnType: CAPPluginReturnPromise)
    ]

    @objc func getHourCycle(_ call: CAPPluginCall) {
        let hourCycle = ExtendedDeviceSettingsPlugin.getHourCycle()

        call.resolve([
            "hourCycle": hourCycle.rawValue
        ])
    }

    // MARK: - Helper

    static func getHourCycle() -> HourCycle {
        let systemHourCycle = Locale.current.hourCycle

        switch systemHourCycle {
        case .zeroToTwentyThree:
            return .h23
        case .oneToTwentyFour:
            return .h24
        case .zeroToEleven:
            return .h11
        case .oneToTwelve:
            return .h12
        @unknown default:
            return .h23
        }
    }
}
