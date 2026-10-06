import { initializeApp, getApps, getApp, FirebaseApp } from 'firebase/app';
import { getAuth, Auth } from 'firebase/auth';
import { getFirestore, Firestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || 'AIzaSyDemoKeyForNirmaanDevEnvironment123',
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || 'nirmaan-app.firebaseapp.com',
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || 'nirmaan-app',
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || 'nirmaan-app.appspot.com',
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || '102938475610',
  appId: import.meta.env.VITE_FIREBASE_APP_ID || '1:102938475610:web:1a2b3c4d5e6f7g8h9i0j',
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID || 'G-NIRMAANDEV01',
};

// Initialize Firebase App instance safely (singleton pattern)
let app: FirebaseApp;
if (!getApps().length) {
  app = initializeApp(firebaseConfig);
} else {
  app = getApp();
}

export const auth: Auth = getAuth(app);
export const db: Firestore = getFirestore(app);

export const isFirebaseConfigured = (): boolean => {
  const key = import.meta.env.VITE_FIREBASE_API_KEY;
  return Boolean(key && !key.includes('your_firebase') && !key.includes('Placeholder'));
};

export default app;
