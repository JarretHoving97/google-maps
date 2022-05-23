package com.whoisup.app;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.view.View;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.RequiresApi;

import com.getcapacitor.Bridge;
import com.getcapacitor.BridgeWebViewClient;
import com.getcapacitor.Plugin;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "Offline")
public class OfflinePlugin extends Plugin {
    private ConnectivityManager connectivityManager;

    @Override
    public void load() {
        connectivityManager = (ConnectivityManager) getContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        bridge.setWebViewClient(new CustomWebViewClient(bridge));
    }

    public Boolean isConnected() {
        NetworkInfo info = connectivityManager.getActiveNetworkInfo();

        if (info == null) {
            return false;
        } else {
            return info.isConnected();
        }
    }

    public class CustomWebViewClient extends BridgeWebViewClient {
        public CustomWebViewClient(Bridge bridge) {
            super(bridge);
        }

        private boolean hasError = false;

        private void handleError(WebResourceRequest request) {
            boolean isForMainFrame = request.isForMainFrame();

            if (isForMainFrame) {
                hasError = true;

                View offlineView = getActivity().findViewById(R.id.offlineview);
                offlineView.setVisibility(View.VISIBLE);

                View webView = getActivity().findViewById(R.id.webview);
                webView.setVisibility(View.INVISIBLE);

                TextView offlineReloadLoadingLabel = getActivity().findViewById(R.id.offlineReloadLoadingLabel);
                offlineReloadLoadingLabel.setVisibility(View.INVISIBLE);

                Button offlineReloadButton = getActivity().findViewById(R.id.offlineReloadButton);

                offlineReloadButton.setOnClickListener(view -> {
                    hasError = false;
                    offlineReloadLoadingLabel.setVisibility(View.VISIBLE);
                    bridge.getWebView().loadUrl(bridge.getConfig().getServerUrl());
                });
            }
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            hasError = false;
            return super.shouldOverrideUrlLoading(view, url);
        }

        @Override
        public void onPageCommitVisible(WebView view, String url) {
            if (!hasError) {
                View offlineView = getActivity().findViewById(R.id.offlineview);
                offlineView.setVisibility(View.INVISIBLE);

                View webView = getActivity().findViewById(R.id.webview);
                webView.setVisibility(View.VISIBLE);
            }

            super.onPageFinished(view, url);
        }

        @RequiresApi(api = Build.VERSION_CODES.M)
        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
            handleError(request);
            super.onReceivedError(view, request, error);
        }

        @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
        @Override
        public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
            handleError(request);
            super.onReceivedHttpError(view, request, errorResponse);
        }
    }
}
