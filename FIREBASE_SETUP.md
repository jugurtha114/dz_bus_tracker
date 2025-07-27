# Firebase Setup Guide for DZ Bus Tracker

This guide will help you set up Firebase Cloud Messaging (FCM) for push notifications in the DZ Bus Tracker app.

## Prerequisites

1. A Google account
2. Access to the [Firebase Console](https://console.firebase.google.com/)
3. Android Studio (for Android setup)
4. Xcode (for iOS setup, if applicable)

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `dz-bus-tracker`
4. Enable/disable Google Analytics as needed
5. Click "Create project"

## Step 2: Add Android App to Firebase

1. In the Firebase console, click "Add app" and select Android
2. Register your app with the following details:
   - **Android package name**: `com.dzbustracker.app.dz_bus_tracker_app`
   - **App nickname**: `DZ Bus Tracker Android`
   - **Debug signing certificate SHA-1**: (Get this from Android Studio or using keytool)

### Getting SHA-1 Fingerprint

For debug builds, run this command in your terminal:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For release builds, use your release keystore:
```bash
keytool -list -v -keystore path/to/your/release-keystore.jks -alias your-key-alias
```

3. Download the `google-services.json` file
4. Replace the placeholder file at `android/app/google-services.json` with the downloaded file

## Step 3: Configure Android Build Files

The following files have already been configured for Firebase:

### android/settings.gradle.kts
- Added Google Services plugin

### android/app/build.gradle.kts  
- Added Google Services plugin

## Step 4: Add iOS App to Firebase (Optional)

1. In the Firebase console, click "Add app" and select iOS
2. Register your app with:
   - **iOS bundle ID**: `com.dzbustracker.app.dzBusTrackerApp`
   - **App nickname**: `DZ Bus Tracker iOS`
3. Download `GoogleService-Info.plist`
4. Add the file to `ios/Runner/` in Xcode
5. Update `ios/Runner/Info.plist` with Firebase configuration

## Step 5: Enable Firebase Cloud Messaging

1. In the Firebase console, go to **Engage > Messaging**
2. Click "Get started" if this is your first time
3. Follow the setup wizard

## Step 6: Configure Notification Settings

### Android Permissions
The app already includes required permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### iOS Permissions
Add to `ios/Runner/Info.plist`:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>This app needs notification permissions to send you bus arrival alerts and important updates.</string>
```

## Step 7: Test Firebase Integration

1. Build and run the app
2. Check the debug console for Firebase initialization logs
3. The app will automatically request notification permissions
4. The FCM token will be registered with your backend API

## Step 8: Backend Integration

Ensure your backend API at `http://0.0.0.0:8007` supports:

1. **Device Token Registration**: `POST /api/v1/notifications/device-tokens/`
2. **Send Notifications**: Your backend should use Firebase Admin SDK to send push notifications

### Example Backend Code (Python/Django)

```python
from firebase_admin import messaging

def send_notification(device_token, title, body, data=None):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        token=device_token,
    )
    
    response = messaging.send(message)
    return response
```

## Step 9: Test Push Notifications

### Via Firebase Console
1. Go to **Engage > Messaging**
2. Click "Send your first message"
3. Enter title and message
4. Select your app
5. Send test message

### Via Backend API
1. Register a device token through the app
2. Use your backend to send a notification
3. Verify the app receives the notification

## Troubleshooting

### Common Issues

1. **"google-services.json not found"**
   - Ensure the file is in `android/app/` directory
   - Verify the package name matches your app

2. **"Firebase not initialized"**
   - Check that Firebase.initializeApp() is called in main.dart
   - Verify google-services.json is correctly configured

3. **Notifications not received**
   - Check notification permissions are granted
   - Verify FCM token is being registered
   - Test with Firebase Console first

4. **Build errors**
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check Android Studio sync issues
   - Verify Gradle files are correctly configured

### Debug Tips

1. **Check FCM Token**
   ```dart
   String? token = await FirebaseMessaging.instance.getToken();
   print('FCM Token: $token');
   ```

2. **Monitor Foreground Messages**
   ```dart
   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     print('Received message: ${message.notification?.title}');
   });
   ```

3. **Check Background Message Handler**
   ```dart
   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
   ```

## Security Considerations

1. **Never commit sensitive Firebase keys** to version control
2. **Use different Firebase projects** for development, staging, and production
3. **Implement proper server-side validation** for device tokens
4. **Rate limit** notification sending to prevent abuse
5. **Validate notification content** before sending

## Production Deployment

Before deploying to production:

1. **Create separate Firebase projects** for staging and production
2. **Update API endpoints** in `lib/config/api_config.dart`
3. **Use release build types** with proper signing certificates
4. **Configure proper notification channels** for Android
5. **Test thoroughly** with different device types and OS versions

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Android Notification Channels](https://developer.android.com/training/notify-user/channels)
- [iOS Push Notifications](https://developer.apple.com/documentation/usernotifications)

## Support

If you encounter issues with Firebase setup:

1. Check the [Firebase Status Page](https://status.firebase.google.com/)
2. Review [FlutterFire issues](https://github.com/firebase/flutterfire/issues)
3. Consult the [Firebase Community](https://firebase.google.com/support)
4. Check the app logs for specific error messages