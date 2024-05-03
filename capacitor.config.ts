/// <reference types="@capacitor-community/privacy-screen" />
/// <reference types="@capacitor/push-notifications" />

import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.whoisup.app',
  appName: 'Amigos',
  bundledWebRuntime: false,
  webDir: 'www',
  server: {
    url: 'https://app.amigosapp.nl',
    allowNavigation: [
      '*.amigosapp.nl',
      'app.amigosapp.nl',
      '*.test.app.amigosapp.nl',
      'qa.app.amigosapp.nl',
      'client.qa.app.amigosapp.nl',
      'com.whoisup.app',
    ],
  },
  plugins: {
    PrivacyScreen: {
      enable: false,
    },
    PushNotifications: {
      presentationOptions: ['badge', 'sound', 'alert'],
    },
  },
  ios: {
    contentInset: 'never',
  },
};

export default config;
