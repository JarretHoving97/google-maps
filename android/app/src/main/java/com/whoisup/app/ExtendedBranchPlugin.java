package com.whoisup.app;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import org.json.JSONException;
import org.json.JSONObject;

import io.branch.referral.Branch;

@CapacitorPlugin(name = "ExtendedBranch")
public class ExtendedBranchPlugin extends Plugin {
    @PluginMethod
    public void getLastAttributedTouchData(PluginCall call) {
        Branch branch = Branch.getInstance();

        if (branch != null) {
            Integer attributionWindow = call.getInt("attributionWindow", 1);
            branch.getLastAttributedTouchData(
                    (jsonObject, error) -> {
                        if (error == null) {
                            if (jsonObject != null) {
                                try {
                                    JSONObject data = jsonObject.getJSONObject("last_attributed_touch_data");
                                    call.resolve(JSObject.fromJSONObject(data));
                                } catch (JSONException ignore) {
                                    // something went wrong while reading json
                                }
                            }
                            return;
                        }
                        call.resolve();
                    }, attributionWindow != null ? attributionWindow : 1);
        } else {
            call.resolve();
        }
    }
}
