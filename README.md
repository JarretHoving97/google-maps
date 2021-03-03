## Created with Capacitor Create

This app was created using the `npx @capacitor/cli create` command, and comes with a very minimal shell for building an app.

### Running this App

To run the App

1. Modify the capacitor.config.json file to point at the correct IP:
- In the iOS simulator localhost should be used
- In the Android emulator 10.0.2.2 should be used (maps to localhost)
- When running on an actual device <your local network IP> should be used

Note:
- the device should be on the same network as your PC
- the required ports should be open (3000 and 3012)

2. Build the frontend for Android OR iOS:

```bash
cd frontend
yarn run android/ios
```

3. Synchronize the project and open the development environment (for Android OR iOS)

```bash
npx cap copy android/ios
npx cap open android/ios
```

4. Run the app on the emulator/simulator/device
- On Android: press the play button on the top-right in Android Studio
- on iOS: ?

5. You should be able to debug the app:
- For Android we use Chrome Inspector (chrome://inspect)
- For iOS we use Safari Web Inspector (?)