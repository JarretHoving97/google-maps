/// <reference types="@capacitor-community/privacy-screen" />
/// <reference types="@capacitor/push-notifications" />

import { CapacitorConfig } from '@capacitor/cli';

let config: CapacitorConfig;

const baseConfig: CapacitorConfig = {
  appId: 'com.whoisup.app',
  appName: 'Amigos',
  bundledWebRuntime: false,
  webDir: 'www',
  plugins: {
    PrivacyScreen: {
      enable: false,
    },
    PushNotifications: {
      presentationOptions: ['badge', 'sound', 'alert'],
    },
  },
};

switch (process.env.NODE_ENV) {
  case 'qa':
    config = {
      ...baseConfig,
      ios: {
        scheme: 'App QA',
        contentInset: 'never',
        handleApplicationNotifications: false,
      },
      server: {
        url: 'https://qa.app.amigosapp.nl',
        allowNavigation: [
          '*.amigosapp.nl',
          'app.amigosapp.nl',
          '*.test.app.amigosapp.nl',
          'qa.app.amigosapp.nl',
          'client.qa.app.amigosapp.nl',
          'com.whoisup.app',
        ],
        androidScheme: 'http',
      },

      // TODO: add android QA flavor
      // android: {
      //   flavor: 'dev'
      // }
    };

    break;

  default:
    config = {
      ...baseConfig,
      ios: {
        scheme: 'App',
        contentInset: 'never',
        handleApplicationNotifications: false,
      },
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
        androidScheme: 'http',
      },

      // TODO: add android QA flavor
      // android: {
      //   flavor: 'dev'
      // }
    };
}

export default config;
