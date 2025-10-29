
# Lecture 11 - 04 Messaging

## Steps to implement

1. Add firebase cloud messaging by
```zsh
flutter pub add firebase_messaging
```
2. Create reference to cloud messaging in `main()`
```dart
final messaging = FirebaseMessaging.instance;
```
3. Request permission from the host device
```dart
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
```
4. Go to **Project Settings > Cloud Messaging** and create a Web Push Key.
<img src="/assets/images/GenerateVapidKey_1.png" alt="Generate VAPID Key - 1" width="600">
<img src="/assets/images/GenerateVapidKey_1.png" alt="Generate VAPID Key - 2" width="600">


5. Add your `VAPID Key` to be able to push to Web.
```dart
const vapidKey = "<YOUR_PUBLIC_VAPID_KEY_HERE>"
```
6. Get your messaging token. This is device specific and you should be saving this. It will not change whilst the app is installed on the device. However, you can always check this token and save it to your server everytime the client launches the app, if it has changed. Wrap it in a `try/catch` so we can run the app on iOS simulator as well where Firebase Cloud Messaging doesn't work.
```dart
String? token;

if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
  token = await messaging.getToken(
    vapidKey: vapidKey,
  );
} else {
  try {
    token = await messaging.getToken();
  } catch (e) {
    print("Error getting token $e");
  }
}
print("Messaging token: $token");
```
7. Create the listener for messages while the app is open:
```dart
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Handling a foreground message: ${message.messageId}');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
    ... // Do whatever you need to do with this message
  });
```
8. Create the function that checks messages that were received while the app is closed:
```dart
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```
and create the function `_firebaseMessagingBackgroundHandler` above `main()`
```dart
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
  print('Message notification: ${message.notification?.body}');
}
```
> Note here we call `Firebase.initializeApp()` because when a message is received while the App is closed, in order to process it, Firebase needs to be initialized.

## Testing messaging

1. Run on an Android device
2. Go to **Messaging** in Firebase Console. 
3. Click **New Campaign**
4. Select **Notification**
5. Add Title and Body
<img src="/assets/images/TestNotification_1.png" alt="Test Notification" width="600">
6. Click on **Send Test Message** and enter the token you read from the page by copying to Clipboard.
<img src="/assets/images/TestNotification_4.png" alt="Copy Token" width="350">
<img src="/assets/images/TestNotification_2.png" alt="Send Test" width="600">
<img src="/assets/images/TestNotification_3.png" alt="Send Test2" width="600">
7. You should now see the notification in your **Debug Console**
```text
D/FLTFireMsgReceiver( 9693): broadcast received for message
I/flutter ( 9693): Handling a foreground message: 0:1730248935174495%bd986069bd986069
I/flutter ( 9693): Message data: {}
I/flutter ( 9693): Message notification:<Notification Title>
I/flutter ( 9693): Message notification: <Notification Body>
```

## Additional Configuration for Flutter Web
Flutter Web requires a service worker. This file is placed in the [Web](/web/) folder of the project [firebase-messaging-sw.js](/web/firebase-messaging-sw.js).
```javascript

importScripts("https://www.gstatic.com/firebasejs/11.6.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/11.6.1/firebase-messaging-compat.js");

const firebaseConfig = {
   apiKey: 'api-key',
   authDomain: 'project-id.firebaseapp.com',
   projectId: 'project-id',
   storageBucket: 'project-id.appspot.com',
   messagingSenderId: 'sender-id',
   appId: 'app-id',
   measurementId: 'G-measurement-id',
 };

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

// todo Set up background message handler
messaging.onBackgroundMessage((message) => {
 console.log("onBackgroundMessage", message);
});
```


