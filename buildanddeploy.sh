#!/bin/bash
echo "Building Main App..."
flutter build web -t lib/main.dart --output=build/web

echo "Building Admin App..."
flutter build web -t lib/main-admin.dart --output=build/web_admin

echo "Deploying to Firebase..."
firebase deploy --only hosting