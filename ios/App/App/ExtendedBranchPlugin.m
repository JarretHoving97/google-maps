#import <Capacitor/Capacitor.h>

CAP_PLUGIN(ExtendedBranchPlugin, "ExtendedBranch",
    CAP_PLUGIN_METHOD(getLastAttributedTouchData, CAPPluginReturnPromise);
)
