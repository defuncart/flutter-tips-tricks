# 16 - PigeonSymbolConflicts

[Pigeon](https://pub.dev/packages/pigeon) is a code generator tool for Flutter which generates code for dart plugins to communicate with the host platform (i.e. iOS, Android etc). This ensures all code is type-safe, drastically improves efficiency while reducing bugs due to manual typos.

However, one major issue which isn't consistently documented is the need for unique filenames to avoid symbol conflicts. Consider the following default pigeon options:

```dart
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  cppOptions: CppOptions(namespace: 'pigeon_example'),
  cppHeaderOut: 'windows/runner/messages.g.h',
  cppSourceOut: 'windows/runner/messages.g.cpp',
  gobjectHeaderOut: 'linux/messages.g.h',
  gobjectSourceOut: 'linux/messages.g.cc',
  gobjectOptions: GObjectOptions(),
  kotlinOut:
      'android/app/src/main/kotlin/dev/flutter/pigeon_example_app/Messages.g.kt',
  kotlinOptions: KotlinOptions(),
  javaOut: 'android/app/src/main/java/io/flutter/plugins/Messages.java',
  javaOptions: JavaOptions(),
  swiftOut: 'ios/Runner/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  objcHeaderOut: 'macos/Runner/messages.g.h',
  objcSourceOut: 'macos/Runner/messages.g.m',
  // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
  objcOptions: ObjcOptions(prefix: 'PGN'),
  copyrightHeader: 'pigeons/copyright.txt',
  dartPackageName: 'pigeon_example_package',
))
```

The kotlin output file is named `Messages.g.kt`. If another plugin uses pigeon and names their output file the same, when an app tries to depend on both packages, then a dex merging compile error occurs: `Type Messages_gKt` is defined multiple times. The solution is to simply rename `Messages.g.kt` to `{PLUGIN_NAME}Messages.g.kt` (or applicable).

`KotlinOptions` contains the property `errorClassName`. As no value is given above, this will default to [`FlutterError`](https://github.com/flutter/packages/blob/main/packages/pigeon/lib/src/kotlin/kotlin_generator.dart#L2215). Now when an app imports two pigeon packages using the default `KotlinOption`, a `Type FlutterError is defined multiple times` error will occur.

Moreover, as alluded to above, `ObjcOptions` has `PGN` as a prefix which needs to be unique, otherwise symbol conflicts will occur.

So, as a rule of thumb, simply use `{PLUGIN_NAME}` as a suffix before `Messages.*` to ensure your plugin has no compatibility issues with other plugins using pigeon:

```dart
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  cppOptions: CppOptions(namespace: 'pigeon_example'),
  cppHeaderOut: 'windows/runner/pigeonexamplemessages.g.h',
  cppSourceOut: 'windows/runner/pigeonexamplemessages.g.cpp',
  gobjectHeaderOut: 'linux/pigeonexamplemessages.g.h',
  gobjectSourceOut: 'linux/pigeonexamplemessages.g.cc',
  gobjectOptions: GObjectOptions(),
  kotlinOut:
      'android/app/src/main/kotlin/dev/flutter/pigeon_example_app/PigeonExampleMessages.g.kt',
  kotlinOptions: KotlinOptions(errorClassName: 'PigeonExampleError'),
  javaOut: 'android/app/src/main/java/io/flutter/plugins/PigeonExampleMessages.java',
  javaOptions: JavaOptions(),
  swiftOut: 'ios/Runner/PigeonExampleMessages.g.swift',
  swiftOptions: SwiftOptions(errorClassName: 'PigeonExampleError'),
  objcHeaderOut: 'macos/Runner/pigeonexamplemessages.g.h',
  objcSourceOut: 'macos/Runner/pigeonexamplemessages.g.m',
  // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
  objcOptions: ObjcOptions(prefix: 'PigeonExample'),
  copyrightHeader: 'pigeons/copyright.txt',
  dartPackageName: 'pigeon_example',
))
```
