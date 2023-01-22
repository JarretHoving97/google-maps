## Building

First specify the correct `server.url` in `capacitor.config.ts`. This can be the public url for the production or qa environment. E.g. `app.example.com` or `qa.app.example.com`. It can also be a local accessible url. E.g. `10.0.0.0:8080`. In the latter case you need to make sure that url is actually accessible from the device you are deploying the app to.

Then make sure you have ran `yarn` and `npx cap sync`.

Next, copy the contents of `CustomMapViewController.swift` into `node_modules/@capacitor-community/google-maps/ios/Plugin/CustomMapViewController.swift`. This is a temporary workaround and should be resolved in the future.

Finally, you can deploy the app to a connected device or upload a binary to the stores.

### The `www` folder

This folder only exists because of legacy reasons. It can actually be safely deleted, except that capacitor requires a `www/index.html` file to exist to be able to run `npx cap copy` for example.

Normally this folder would contain the built version of the app. But since we're serving the contents of the app with the help of `server.url`, we do not need this.

Advantages of doing it like this are:

- Easier updating (no native update needs to be done)
- Cookies working like they should\*
- Secure contexts working like it should\* (needed to be able to access certain web-apis)
- No Cross Origin issues\*

* These issues might be fixed in a newer version of Capacitor. Maybe as of v4.6.0

Disavantages:

- No offline support

## Debugging

A guide on debugging WebViews / Webpages on native platforms can be found here: https://ionicframework.com/docs/troubleshooting/debugging. The guide is tailored to Ionic, but most of its explanation is the same with any other framework.

## Launch and Splash assets

### iOS

**Step 1:**

Add `assets/icon.svg`

**Step 2:**

```bash
# npm install -g capacitor-assets
npx capacitor-assets generate --iconBackgroundColor '#FA7B1E' --splashBackgroundColor '#FA7B1E' --splashBackgroundColorDark '#FA7B1E' --iconBackgroundColorDark '#FA7B1E' --ios --logoSplashScale 1
```

### Android

Follow tutorial in repository `splitt-capacitor`
