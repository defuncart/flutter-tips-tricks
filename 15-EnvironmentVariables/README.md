# 15 - Environment Variables

API keys and other secrets should not be under source control, even in private repos. Instead we should inject these values as environment variables at build time.

## Dart

One of the most popular approaches is to use `--dart-defines-from-file` which loads a json key-value object at build time.

For each flavor (i.e. dev, prod), add the files `.env/{FLAVOR}.json`

```json
{
    "MY_KEY": "VALUE"
}
```

Ensure these files can never be accidentally pushed to origin by updating `.gitignore`:

```
# api keys
.env/**
```

Now where ever "MY_KEY" is required, load the value using `String.fromEnvironment`:

```dart
const MY_KEY = String.fromEnvironment('MY_KEY');
```

Now when running the applicable, ensure that `--dart-define-from-file` is used:

```sh
flutter run -t lib/main_prod.dart --flavor prod --dart-define-from-file=.env/prod.json
```

By design, dart environment variables are not passed by flutter to native layers (see [issue](https://github.com/flutter/flutter/issues/138793) for more information). Thus, if "MY_KEY" is also required on the native layer, some more work needs to be done.

## Android

In `android/app/build.gradle`, parse the dart defines and inject as native android env vars

```
// dart defines are not passed by default to the native layer
def dartEnv = []
if (project.hasProperty('dart-defines')) {
    dartEnv = project.property('dart-defines')
            .split(',')
            .collectEntries { entry ->
                def pair = new String(entry.decodeBase64(), 'UTF-8').split('=')
                [(pair.first()): pair.last()]
            }
}

android {
    ...

    defaultConfig {
        ...

        manifestPlaceholders += [
            MY_KEY: dartEnv.MY_KEY,
        ]
    }
}
```

These native android env vars can be used in `android/app/src/main/AndroidManifest.xml` (or applicable)

```
<meta-data
    android:name="com.my.sdk.MY_KEY"
    android:value="${MY_KEY}" />
```

## iOS

In `ios/Runner/Info.plist` pipe the raw dart define output to be readable within swift code:

```
<key>DART_DEFINES</key>
<string>$(DART_DEFINES)</string>
```


Then in `ios/Runner/AppDelegate.swift` (or applicable), parse this output and inject as native iOS env vars

```
// dart defines are not passed by default to the native layer
var dartDefinesDict = [String:String]()
let dartDefinesString = Bundle.main.infoDictionary!["DART_DEFINES"] as! String
for definedValue in dartDefinesString.components(separatedBy: ",") {
    let decoded = String(data: Data(base64Encoded: definedValue)!, encoding: .utf8)!
    let values = decoded.components(separatedBy: "=")
    dartDefinesDict[values[0]] = values[1]
}
MyService.provideAPIKey(dartDefinesDict["MY_KEY"]!)
```

## CD Pipelines

To ensure that the env vars can be injected in CD pipelines, firstly encyrpt the file

```
cat .env/prod.json | base64 | pbcopy
```

and save it as an environmental variable (i.e. DART_DEFINES) in the CD pipeline.

Then add a pre-build step to decrypt the env vars

```
# decrypt dart defines from env vars 
echo "$DART_DEFINES" | base64 --decode > .env/prod.json
```

and use this file when building the application

```sh
flutter build -t lib/main_prod.dart --flavor prod --dart-define-from-file=.env/prod.json
```
