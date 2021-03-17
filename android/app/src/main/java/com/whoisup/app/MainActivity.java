package com.whoisup.app;

import android.content.Intent;
import android.os.Bundle;

import com.byteowls.capacitor.oauth2.OAuth2ClientPlugin;
import com.facebook.CallbackManager;
import com.facebook.FacebookSdk;

import com.getcapacitor.BridgeActivity;
import com.getcapacitor.Plugin;

import java.util.ArrayList;

public class MainActivity extends BridgeActivity {

  private CallbackManager callbackManager;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Custom added for facebook
    FacebookSdk.sdkInitialize(this.getApplicationContext());
    callbackManager = CallbackManager.Factory.create();

    // Initializes the Bridge
    this.init(savedInstanceState, new ArrayList<Class<? extends Plugin>>() {{
      // Additional plugins you've installed go here
      add(OAuth2ClientPlugin.class);
      // Ex: add(TotallyAwesomePlugin.class);
      add(com.byteowls.capacitor.oauth2.OAuth2ClientPlugin.class);

    }});
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

}
