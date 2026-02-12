package com.whoisup.app;

import android.content.Intent;
import android.os.Bundle;

import android.webkit.CookieManager;

import androidx.activity.EdgeToEdge;

import com.facebook.CallbackManager;

import com.getcapacitor.BridgeActivity;
import com.getcapacitor.community.safearea.SafeAreaPlugin;

public class MainActivity extends BridgeActivity {

  private CallbackManager callbackManager;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    // Initialize OfflinePlugin;
    registerPlugin(OfflinePlugin.class);
    registerPlugin(BranchDeepLinksPlugin.class);
    registerPlugin(ExtendedBranchPlugin.class);
    registerPlugin(ExtendedStreamPlugin.class);
    registerPlugin(ExtendedDeviceSettingsPlugin.class);
    registerPlugin(ExtendedCalendarPlugin.class);
    super.onCreate(savedInstanceState);

    EdgeToEdge.enable(this);
    SafeAreaPlugin.setSystemBarsStyle(this, SafeAreaPlugin.SystemBarsStyle.LIGHT);

    callbackManager = CallbackManager.Factory.create();
  }

  @Override
  protected void onNewIntent(Intent intent) {
    this.setIntent(intent);
    super.onNewIntent(intent);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    if (callbackManager.onActivityResult(requestCode, resultCode, data)) {
      return;
    }
  }

  public CallbackManager getCallbackManager() {
    return callbackManager;
  }

  @Override
  public void onPause() {
    super.onPause();

    CookieManager.getInstance().flush();
  }

}
