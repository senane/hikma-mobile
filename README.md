# hikma-mobile

Hikma Health, Inc. Mobile Application

## Getting Started

This project is a starting point for a Flutter application.

### Install dependencies

[Install Flutter](https://flutter.dev/docs/get-started/install)

To make sure all dependencies are installed and working run

```
$ flutter doctor
```

and follow instructions.

### Connect a device

#### On an emulator

iOS emulator (MacOS):

```
$ open -a Simulator
```

For an Android emulator, follow [these instructions](https://flutter.dev/docs/get-started/install/macos#android-setup).

#### On a mobile device

Connect your device to your computer via USB

[Set up debug mode on your Android](https://www.makeuseof.com/tag/what-is-usb-debugging-mode-on-android-makeuseof-explains/)

### Run the app

#### Using Android Studio (Recommended)

1. [Set up Android Studio](https://flutter.dev/docs/get-started/editor)
2. Android Studio > Open an existing Android Studio project > Select hikma-mobile > Open
3. Click the green play button at the top of your screen.

#### Using the command line


```
$ cd hikma-mobile
$ flutter run
```


If you have multiple devices connected, use `$ flutter -d [device-ID] run`.

You may encounter the error `Target file "lib/main.dart" not found.` This is because flutter is expecting a `.dart` file with the name `main`, but the file is called `app.dart` in this repository. If this is the case, try

```
$ cd lib
$ cp app.dart main.dart
$ cd ..
```

then try `$ flutter run` again

## More help

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.io/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.