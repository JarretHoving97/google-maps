import Capacitor
import Branch

@objc(ExtendedBranchPlugin)
public class ExtendedBranchPlugin: CAPPlugin {
    @objc func getLastAttributedTouchData(_ call: CAPPluginCall) {
        let attributionWindow = call.getInt("attributionWindow", 1)

        DispatchQueue.main.async {
            Branch.getInstance().lastAttributedTouchData(withAttributionWindow: attributionWindow) { (result, error) in
                guard let json = result?.lastAttributedTouchJSON else {
                    call.resolve()
                    return
                }
                let js = json["data"] as? NSDictionary
                call.resolve(["data": js ?? JSObject()])
            }
        }
    }
}
