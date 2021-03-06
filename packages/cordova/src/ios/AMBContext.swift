class AMBContext {
    static weak var plugin: AMBPlugin!

    let command: CDVInvokedUrlCommand

    init(_ command: CDVInvokedUrlCommand) {
        self.command = command
    }

    var plugin: AMBPlugin {
        return AMBContext.plugin
    }

    var commandDelegate: CDVCommandDelegate {
        return plugin.commandDelegate
    }

    var opts: NSDictionary? {
        return command.argument(at: 0) as? NSDictionary
    }

    func optString(_ key: String) -> String? {
        return opts?.value(forKey: key) as? String
    }

    func optMaxAdContentRating() -> GADMaxAdContentRating? {
        switch optString("maxAdContentRating") {
        case "G":
            return GADMaxAdContentRating.general
        case "MA":
            return GADMaxAdContentRating.matureAudience
        case "PG":
            return GADMaxAdContentRating.parentalGuidance
        case "T":
            return GADMaxAdContentRating.teen
        default:
            return nil
        }
    }

    func optChildDirectedTreatmentTag() -> Bool? {
        return opts?["tagForChildDirectedTreatment"] as? Bool
    }

    func optUnderAgeOfConsentTag() -> Bool? {
        return opts?["tagForUnderAgeOfConsent"] as? Bool
    }

    func optTestDeviceIds() -> [String]? {
        if let testDeviceIds = opts?["testDeviceIds"] as? [String] {
            return testDeviceIds
        }
        return nil
    }

    func sendResult(_ message: CDVPluginResult?) {
        self.commandDelegate.send(message, callbackId: command.callbackId)
    }

    func success() {
        self.sendResult(CDVPluginResult(status: CDVCommandStatus_OK))
    }

    func success(_ message: Bool) {
        self.sendResult(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message))
    }

    func success(_ message: UInt) {
        self.sendResult(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message))
    }

    func success(_ message: [String: Any]) {
        self.sendResult(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message))
    }

    func error() {
        self.sendResult(CDVPluginResult(status: CDVCommandStatus_ERROR))
    }

    func error(_ message: Error?) {
        self.sendResult(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message?.localizedDescription))
    }
}
