#!/usr/bin/env bash
# Builds gym-buddy.apk without Gradle (Linux, or WSL on Windows).
# Needs: a JDK (javac, keytool), aapt, dalvik-exchange (dx), zipalign, apksigner.
#   Ubuntu: sudo apt install default-jdk-headless aapt dalvik-exchange zipalign apksigner libandroid-23-java
# Usage:
#   ANDROID_JAR=/path/to/android-34/android.jar KS_PASS=yourpassword ./build-apk.sh
# The signing key (KEYSTORE, default ./gymbuddy.jks) is created on first run. Keep it private and
# keep using the same one: Android only installs an update over an app signed with the same key.
set -euo pipefail
cd "$(dirname "$0")"

: "${ANDROID_JAR:?set ANDROID_JAR to an android.jar (API 34) used for compiling}"
: "${KS_PASS:?set KS_PASS to the keystore password}"
: "${FRAMEWORK_JAR:=/usr/share/java/com.android.android-23.jar}" # only used by aapt for resources
: "${KEYSTORE:=gymbuddy.jks}"

rm -rf build && mkdir -p build/gen build/classes
aapt package -f -M AndroidManifest.xml -S res -I "$FRAMEWORK_JAR" -J build/gen -F build/res.apk
javac --release 8 -cp "$ANDROID_JAR" -d build/classes $(find src build/gen -name '*.java')
java -cp /usr/share/java/com.android.dx.jar com.android.dx.command.Main --dex --output=build/classes.dex build/classes
cp build/res.apk build/app.apk
(cd build && aapt add app.apk classes.dex > /dev/null)
zipalign -f -p 4 build/app.apk build/aligned.apk

if [ ! -f "$KEYSTORE" ]; then
  keytool -genkeypair -keystore "$KEYSTORE" -alias gymbuddy -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass "$KS_PASS" -keypass "$KS_PASS" -dname "CN=Gym Buddy, O=Ketan Shrirao, C=IN"
fi
apksigner sign --ks "$KEYSTORE" --ks-key-alias gymbuddy --ks-pass "pass:$KS_PASS" --out gym-buddy.apk build/aligned.apk
apksigner verify gym-buddy.apk
echo "Built gym-buddy.apk"
