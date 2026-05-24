/* Firebase Cloud Messaging service worker (Web).
 * Keep in sync with lib/firebase_options.dart → [DefaultFirebaseOptions.web]
 * and lib/config/firebase_web_vapid.dart.
 */
importScripts('https://www.gstatic.com/firebasejs/11.6.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.6.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBxaQ80B3Au9KiMwk2m1lBLScMaEruSelI',
  authDomain: 'toolmonitoring.firebaseapp.com',
  projectId: 'toolmonitoring',
  storageBucket: 'toolmonitoring.firebasestorage.app',
  messagingSenderId: '264867704267',
  appId: '1:264867704267:web:80e22ca914d552118a5a4e',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title ?? 'Tool Monitoring';
  const options = {
    body: payload.notification?.body ?? '',
    icon: '/icons/Icon-192.png',
    data: payload.data,
  };
  return self.registration.showNotification(title, options);
});
