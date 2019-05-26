# 05 - Change Package Name/Bundle Id

By default, when a new Flutter project is created, the package name (Android) and Bundle Id (iOS) is automatically set to *com.example.app_name* and *com.example.appName* respectively. When releasing on the store, we need to specify our own custom identifiers (generally reverse domain notation).
 
## Android

To change the *application id*, open **android/app/build.grade** and change *applicationId* in *defaultConfig* to com.mydomain.app_name

```
defaultConfig {
    applicationId "com.mydomain.app_name"
    minSdkVersion 16
    targetSdkVersion 28
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
    testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
}
```

Note that it is possible to overwrite the *package name* for debug/profile/release builds (i.e. **android/app/src/debug/AndroidManifest.xml**), however it doesn't seem to be necessary. Moreover, in **android/app/src/main/java/com/example/app_name/MainActivity.java**

```java
package com.example.app_name;
```

the package name must represent the folder structure, however it does not seem to be necessary to update this to match the app's bundle id.

## iOS

On iOS, open **ios/Runner.xcodeproj/project.pbxproj** and change *PRODUCT_BUNDLE_IDENTIFIER* for the debug, profile and release configurations to com.mydomain.appName.

```
97C147071CF9000F007C117D /* Release */ = {
    isa = XCBuildConfiguration;
    baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
    buildSettings = {
        ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
        CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";
        ENABLE_BITCODE = NO;
        FRAMEWORK_SEARCH_PATHS = (
            "$(inherited)",
            "$(PROJECT_DIR)/Flutter",
        );
        INFOPLIST_FILE = Runner/Info.plist;
        LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
        LIBRARY_SEARCH_PATHS = (
            "$(inherited)",
            "$(PROJECT_DIR)/Flutter",
        );
        PRODUCT_BUNDLE_IDENTIFIER = com.mydomain.appName;
        PRODUCT_NAME = "$(TARGET_NAME)";
        VERSIONING_SYSTEM = "apple-generic";
    };
    name = Release;
};
```

## Specify on Create

It is actually possible to specify the package name/bundle id on project create:

```
flutter create --org com.mydomain app_name
```

For Android this will not only change **android/app/build.grade**, but also all launch manifests (i.e. **android/app/src/debug/AndroidManifest.xml**) and MainActivity.java.

In VS Code, the organization can be specified in **settings.json**:

```json
"dart.flutterCreateOrganization": "com.mydomain"
```

## Resources

[Android API: Application ID](https://developer.android.com/studio/build/application-id)
