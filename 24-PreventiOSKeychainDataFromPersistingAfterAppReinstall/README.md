# 24 Prevent iOS Keychain Data From Persisting After App Reinstall

When storing local sensitive user data such as tokens and passwords, [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) is one of the most popular options.

Many developers, however, are surprised to discover that on iOS when deleting an app and re-installing it, local secure storage is not always removed.

## The Problem

Under the hood, `flutter_secure_storage` uses [Keychain](https://developer.apple.com/documentation/security/keychain-services) for iOS. Unlike Android’s Shared Preferences or `NSUserDefaults` on iOS, Keychain is not automatically wiped when an app is deleted. This is the intentional behavior by Apple, as Keychain is designed for:
* Credentials that should survive reinstalls (e.g. password managers)
* Secure data shared across apps from the same developer (via entitlements)
* Long-lived authentication material

So when a Flutter app is deleted and reinstalled, existing Keychain entries may still be accessible. While this behavior is desirable for many apps, you may need a different approach if your security model requires a true fresh state after reinstall.

## The Solution

From a fresh app state perspective, the most reliable solution is:
- Detect whether this is a fresh install (i.e. via a flag stored in local preferences)
- If yes,
  - clear Keychain-backed storage
  - Persist a flag indicating the app has launched before

As `shared_preferences` are wiped on uninstall while Keychain items persist (within the same access group and service configuration), this ensures empty secure data on fresh installs.

The following check should run during app initialization i.e. before authentication logic etc. executes:

```dart
Future<void> removeIOSSecureDataOnFreshInstall(
  SharedPreferences prefs,
  FlutterSecureStorage storage,
) async {
  if (defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }

  const hasLaunchedKey = 'secureStorageHasLaunchedBefore';
  final hasLaunchedBefore = prefs.getBool(hasLaunchedKey) ?? false;
  if (!hasLaunchedBefore) {
    log('Fresh install detected — clearing secure storage');
    await storage.deleteAll();
    await prefs.setBool(hasLaunchedKey, true);
  }
}
```

Another solution would be to prefix all keys with a locally generated install ID. However, for most applications, clearing the Keychain on first launch after reinstall is simpler and sufficiently robust.
