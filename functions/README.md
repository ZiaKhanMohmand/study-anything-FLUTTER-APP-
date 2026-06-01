# Functions

This folder contains the Firebase Cloud Function that proxies Groq requests.

## Required secret

Set the Groq API key as a Firebase secret before deploying:

```bash
firebase functions:secrets:set GROQ_API_KEY
```

## Deploy

```bash
cd functions
npm install
firebase deploy --only functions:groqProxy
```

## Client configuration

The Flutter app calls the proxy at:

`https://us-central1-study-anything-aed2b.cloudfunctions.net/groqProxy`
