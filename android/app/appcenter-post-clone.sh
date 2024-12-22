#!/usr/bin/env bash
# Place this script in project/android/app/

cd .. 

# fail if any command fails
set -e
# debug log
set -x

cd ..

# Clone the Flutter SDK (ensure you're using the correct branch)
git clone -b beta https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

flutter channel stable
flutter doctor

echo "Installed flutter to `pwd`/flutter"

# Export keystore for release
echo "$KEY_JKS" | base64 --decode > release-keystore.jks

# Generate .env file with App Center environment variables
echo "API_URL=$API_URL" > .env
echo "DEBUG=False" >> .env

# Display generated .env file for debugging (optional)
cat .env

# Build APK
# If you get "Execution failed for task ':app:lintVitalRelease'." error, uncomment next two lines
# flutter build apk --debug
# flutter build apk --profile
flutter build apk --release

# Copy the APK where AppCenter will find it
mkdir -p android/app/build/outputs/apk/; mv build/app/outputs/apk/release/app-release.apk $_

