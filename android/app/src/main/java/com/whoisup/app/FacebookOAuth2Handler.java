package com.whoisup.app;

import android.app.Activity;
import android.util.Log;

import com.byteowls.capacitor.oauth2.handler.AccessTokenCallback;
import com.byteowls.capacitor.oauth2.handler.OAuth2CustomHandler;
import com.facebook.AccessToken;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.Profile;
import com.facebook.login.DefaultAudience;
import com.facebook.login.LoginBehavior;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.getcapacitor.PluginCall;

import java.util.Arrays;
import java.util.Collections;

public class FacebookOAuth2Handler implements OAuth2CustomHandler {

  @Override
  public void getAccessToken(Activity activity, PluginCall pluginCall, final AccessTokenCallback callback) {
    AccessToken accessToken = AccessToken.getCurrentAccessToken();
//    Profile profile = Profile.getCurrentProfile();
//    if (AccessToken.isCurrentAccessTokenActive()) {
//      callback.onSuccess(accessToken.getToken());
//      Log.e("OK", "Current access token active");
//    } else {
      LoginManager l = LoginManager.getInstance();
      String[] permissions = new String[] { "public_profile", "email" };
      l.logInWithReadPermissions(activity, Arrays.asList(permissions));
//      l.logInWithReadPermissions(activity, Collections.singletonList("public_profile"));
      l.setLoginBehavior(LoginBehavior.WEB_ONLY);
      l.setDefaultAudience(DefaultAudience.NONE);
      l.registerCallback(((MainActivity) activity).getCallbackManager(), new FacebookCallback<LoginResult>() {
        @Override
        public void onSuccess(LoginResult loginResult) {
          callback.onSuccess(loginResult.getAccessToken().getToken());
        }

        @Override
        public void onCancel() {
          callback.onCancel();
        }

        @Override
        public void onError(FacebookException error) {
          callback.onCancel();
        }
      });
//    }

  }

  @Override
  public boolean logout(Activity activity, PluginCall pluginCall) {
    LoginManager.getInstance().logOut();
    return true;
  }
}
