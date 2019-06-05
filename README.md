# hikma_health

Hikma Health, Inc. Mobile Application

## Getting Started

This project is a starting point for a Flutter application.

1. [Install Flutter](https://flutter.dev/docs/get-started/install)

2. Run `$ flutter doctor` to make sure all dependencies are installed and working.

3. `$ cd hikma-mobile`

4. MacOS: To run on an iOS emulator, `$ open -a Simulator`. For an Android emulator, follow [these instructions](https://flutter.dev/docs/get-started/install/macos#android-setup).

5. `$ flutter run`. If you have multiple devices connected, use `$ flutter -d [device-ID] run`.

   You may encounter the error `Target file "lib/main.dart" not found.` This is because flutter is expecting a `.dart` file with the name `main`, but the file is called `app.dart` in this repository. If this is the case, try

   ```
   $ cd lib
   $ cp app.dart main.dart
   $ cd ..
   ```

   then try `$ flutter run` again

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.io/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
