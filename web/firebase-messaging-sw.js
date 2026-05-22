// See this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/main/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyDBBaqmybxqA3Ak9BzLnsEubAuGBn_vrp8',
    appId: '1:1055393658402:web:401934657b102459003c7b',
    messagingSenderId: '1055393658402',
    projectId: 'csen268-f25',
    authDomain: 'csen268-f25.firebaseapp.com',
    storageBucket: 'csen268-f25.firebasestorage.app',
    measurementId: 'G-EJGFTXNNDB',
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});