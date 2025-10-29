// Import and initialize the Firebase SDK
// https://firebase.google.com/docs/web/setup#access-firebase
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

const firebaseConfig = {
    apiKey: "AIzaSyDBBaqmybxqA3Ak9BzLnsEubAuGBn_vrp8",
    authDomain: "csen268-f25.firebaseapp.com",
    projectId: "csen268-f25",
    storageBucket: "csen268-f25.firebasestorage.app",
    messagingSenderId: "1055393658402",
    appId: "1:1055393658402:web:401934657b102459003c7b",
    measurementId: "G-EJGFTXNNDB"
};

firebase.initializeApp(firebaseConfig);

// This is required to get background messages.
const messaging = firebase.messaging();
