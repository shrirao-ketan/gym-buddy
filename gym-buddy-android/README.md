# Gym Buddy for Android

Android app for **Gym Buddy by Ketan Shrirao**: a workout checklist (Monday–Saturday, Sunday rest), automatic step counting, nutrition guides and a Spotify page.

The app is a thin shell: a full-screen WebView that loads the live Gym Buddy web app at https://gym-buddy-9e12d.web.app. When the web app is redeployed, the Android app picks up the changes without a rebuild. It needs an internet connection.

## Install on your phone

1. Download `gym-buddy.apk` to your phone (from this repo's **Releases** page, or copy it over by cable).
2. Open it. If Android asks, allow installs from this source (Chrome, Files, or whichever app you opened it with).
3. Open **Gym Buddy** and answer the first-time questions.

Needs Android 7.0 (API 24) or newer.

## Things to know

- **Your data lives in Firebase, tied to this install.** The app signs you in anonymously, so uninstalling the app (or clearing its storage) loses access to your data. The same web app opened in Chrome is a separate account.
- **Steps count only while the app is open.** The app keeps the screen on while it is open, because the phone's motion sensor stops when the screen sleeps.
- **Updating:** a new APK installs over the old one only if it is signed with the same key. Keep the signing key private and reuse it (see below).

## What is in this folder

```
AndroidManifest.xml                          app id com.ketanshrirao.gymbuddy, internet permission, launcher
src/com/ketanshrirao/gymbuddy/MainActivity.java   the WebView shell (keeps screen on, opens other sites outside the app)
res/                                          app name, icon (dumbbell logo, adaptive icon)
build-apk.sh                                  builds and signs the APK without Gradle
gym-buddy.apk                                 the built, signed app
```

To point the app at a different deployment, change `HOST` in `MainActivity.java` and rebuild.

## Rebuild the APK (Linux or WSL)

```
sudo apt install default-jdk-headless aapt dalvik-exchange zipalign apksigner libandroid-23-java
# download an android.jar for API 34, for example from https://github.com/Sable/android-platforms
ANDROID_JAR=/path/to/android-34/android.jar KS_PASS=your-password bash build-apk.sh
```

The first run creates `gymbuddy.jks`, your signing key. **Never commit it** (it is in `.gitignore`) and back it up somewhere safe. Rebuilds must reuse the same key and password so the new APK can update the installed app.

## Status

The APK is built, signed (APK Signature Scheme v2/v3) and passes `aapt` and `apksigner` checks. It has not yet been run on a physical phone, so please test the step counter and the Spotify player on your device.
