# Questify Web Link Setup

## Current Status
The project is already prepared for Firebase Hosting.

These files are ready:
- `firebase.json`
- `.firebaserc`
- `deploy_web_hosting.bat`

## Why the public link is not already live
Firebase Hosting deployment requires a Firebase account login on this machine.

The CLI currently returns:

`Failed to authenticate, have you run firebase login?`

That means the project is ready, but the final deploy must be done after one Firebase login from your side.

## Steps To Publish The Web App
Open terminal in:

`C:\Users\zubai\Desktop\flutter project`

Run:

```cmd
npx firebase-tools login
```

After login finishes, run:

```cmd
deploy_web_hosting.bat
```

## Your Permanent Public Links
After successful deploy, share either of these:

- `https://deadline-defender-a272c.web.app`
- `https://deadline-defender-a272c.firebaseapp.com`

## What The Deploy Script Does
1. Builds Flutter web
2. Deploys `build/web` to Firebase Hosting
3. Keeps Flutter web routing working using rewrite rules

## Important Note
Because this is your Firebase project, login must be completed with your own Google/Firebase account on this machine.
