package com.whoisup.app;

import android.app.Activity;

import com.byteowls.capacitor.oauth2.handler.AccessTokenCallback;
import com.byteowls.capacitor.oauth2.handler.OAuth2CustomHandler;
import com.facebook.AccessToken;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.login.DefaultAudience;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.getcapacitor.PluginCall;

import org.jetbrains.annotations.NotNull;

import java.util.Arrays;

public class FacebookOAuth2Handler implements OAuth2CustomHandler {

  @Override
  public void getAccessToken(Activity activity, PluginCall pluginCall, final AccessTokenCallback callback) {
    AccessToken accessToken = AccessToken.getCurrentAccessToken();
    if (accessToken != null && !accessToken.isExpired()) {
      callback.onSuccess(accessToken.getToken());
    } else {
      LoginManager l = LoginManager.getInstance();
      l.logInWithReadPermissions(activity, Arrays.asList("public_profile", "email"));
      l.setDefaultAudience(DefaultAudience.NONE);
      LoginManager.getInstance().registerCallback(((MainActivity) activity).getCallbackManager(), new FacebookCallback<LoginResult>() {
        @Override
        public void onSuccess(LoginResult loginResult) {
          callback.onSuccess(loginResult.getAccessToken().getToken());
        }

        @Override
        public void onCancel() {
          callback.onCancel();
        }

        @Override
        public void onError(@NotNull FacebookException error) {
          callback.onCancel();
        }
      });
    }
  }

  @Override
  public boolean logout(Activity activity, PluginCall pluginCall) {
    LoginManager.getInstance().logOut();
    return true;
  }
}
