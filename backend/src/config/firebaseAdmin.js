/**
 * Firebase Admin SDK Configuration
 * Used for server-side token verification and Firestore administration
 */
const admin = require('firebase-admin');
const { cert, applicationDefault } = require('firebase-admin/app');
const { getAuth: getAdminAuth } = require('firebase-admin/auth');
const { getFirestore: getAdminFirestore } = require('firebase-admin/firestore');
const config = require('./environment');

let isInitialized = false;
let hasFullServiceAccount = false;

function initFirebaseAdmin() {
  if (isInitialized && admin.getApps().length > 0) {
    return admin;
  }

  const { projectId, clientEmail, privateKey } = config.firebase || {};

  try {
    // Only initialize if valid service account credentials or ADC are provided
    if (clientEmail && privateKey && privateKey.trim() !== '') {
      admin.initializeApp({
        credential: cert({
          projectId: projectId || 'nirman-e15ef',
          clientEmail,
          privateKey,
        }),
      });
      isInitialized = true;
      hasFullServiceAccount = true;
      console.log('[FirebaseAdmin] Initialized successfully with Service Account credentials');
    } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      admin.initializeApp({
        credential: applicationDefault(),
        projectId: projectId || 'nirman-e15ef',
      });
      isInitialized = true;
      hasFullServiceAccount = true;
      console.log('[FirebaseAdmin] Initialized successfully with Application Default Credentials');
    } else if (process.env.FIREBASE_AUTH_EMULATOR_HOST) {
      // If running with Firebase Local Emulator Suite
      admin.initializeApp({
        projectId: projectId || 'nirman-e15ef',
      });
      isInitialized = true;
      console.log('[FirebaseAdmin] Initialized with Firebase Auth Emulator');
    } else if (projectId && projectId === 'nirman-e15ef') {
      // Application Default Credentials with genuine project ID
      admin.initializeApp({
        credential: applicationDefault(),
        projectId: 'nirman-e15ef',
      });
      isInitialized = true;
      console.log('[FirebaseAdmin] Initialized with Project ID nirman-e15ef (Application Default Credentials)');
    } else {
      isInitialized = false;
    }
  } catch (error) {
    if (!/already exists/i.test(error.message)) {
      console.warn('[FirebaseAdmin] Initialization warning:', error.message);
    }
  }

  return admin;
}

initFirebaseAdmin();

module.exports = {
  admin,
  isConfigured: () => isInitialized && admin.getApps().length > 0,
  getAuth: () => (isInitialized && admin.getApps().length > 0 ? getAdminAuth() : null),
  getFirestore: () => (isInitialized && hasFullServiceAccount && admin.getApps().length > 0 ? getAdminFirestore() : null),
};
