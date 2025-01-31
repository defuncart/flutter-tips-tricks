# 14 - Local Native Api Keys

When integrating third part packages, some require native api keys on the android and iOS level. When these keys are only required on the native level and not the dart level, one solution is to create local secret files which are not under source control.

## Android

Create the file `/android/apikeys.properties`

```
MY_KEY=VALUE
```

which is read in `android/app/build.gradle`

```
def apiKeyProperties = new Properties()
def apiKeyPropertiesFile = rootProject.file('apikeys.properties')
if (apiKeyPropertiesFile.exists()) {
    apiKeyPropertiesFile.withReader('UTF-8') { reader ->
        apiKeyProperties.load(reader)
    }
}

android {
    ...

    defaultConfig {
        ...

        manifestPlaceholders += [
            MY_KEY: apiKeyProperties.getProperty("MY_KEY")
        ]
    }
}
```

and used in `android/app/src/main/AndroidManifest.xml`

```
<meta-data
    android:name="com.my.sdk.MY_KEY"
    android:value="${MY_KEY}" />
```

Ensure this file can never be accidentally pushed to origin by updating `.gitignore`:

```
# api keys
/android/apikeys.properties
```

## iOS

Create the file `ios/Flutter/ApiKeys.xcconfig`

```
MY_KEY = VALUE
```

which is imported in all relavent flutter mode configs, i.e. `ios/Flutter/Debug.xcconfig`, `ios/Flutter/Release.xcconfig`  etc.

```
#include "ApiKeys.xcconfig"
```

and used in `ios/Runner/Info.plist`

```
<key>MyKey</key>
<string>$MY_KEY</string>
```

Ensure this file can never be accidentally pushed to origin by updating `.gitignore`:

```
# api keys
ios/Flutter/ApiKeys.xcconfig
```
