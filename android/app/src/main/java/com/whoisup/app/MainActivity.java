package com.whoisup.app;

import android.content.Intent;
import android.os.Bundle;
import android.webkit.CookieManager;

import com.byteowls.capacitor.oauth2.OAuth2ClientPlugin;
import com.facebook.CallbackManager;
import com.facebook.FacebookSdk;

import com.getcapacitor.BridgeActivity;
import com.getcapacitor.Plugin;

import java.util.ArrayList;

public class MainActivity extends BridgeActivity {

  private CallbackManager callbackManager;

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
