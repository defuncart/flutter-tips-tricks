# 11 - CI Pipeline

A Continuous Integration (CI) Pipeline is an automated workflow often executed before the integration of new code into a project. This workflow can be used to build, test, deploy and ensure code consistency across a project. Thus errors can be identified much earlier in the development process, while the automation of this workflow frees up the development team to concentrate on development as opposed to dev ops.

## Code Compilation

One of the first basic steps is to determine if the dart code is compilable. This can be achieved by utilized the dart analyzer with only errors as being fatal:

```sh
flutter analyze --no-fatal-infos --no-fatal-warnings
```

## Linting

Linting is the process of checking source code for programmatic as well as stylistic errors. Dart has a build in analyzer, and by default, [flutter_lints](https://pub.dev/packages/flutter_lints) is included with all newly created flutter projects. To ensure that the project's code adheres to the lint settings, as expected, the dart analyzer can be used:

```sh
flutter analyze
```

## Code Formatting

One useful step to ensure code consistency across a project is to check whether each file is formatted using the same formatting settings. This can be achieved using the dart formatter:

```sh
dart format --set-exit-if-changed
```

Here if there are any changed files, then exit 1 occurs and pipeline will stop. If your project supports a different line length (i.e. 120) than the default 80, this can be optionally passed in via parameter `-l 120`.

## Out of Sync Pub Dependencies

When a new version of a package is updated to pub.dev, your local dependencies may change. To ensure that all developers and build machines are using the same package versions, a simple step can be added:

```sh
flutter pub get

if [[ $(git status -s) ]]; then
    echo "Found uncommitted pubspec.lock changes"
    git status -s
    exit 1
fi
```

## Out of Sync Pod Dependencies

CocoaPods is a dependency manager for Swift and Objective-C Cocoa projects which Flutter uses for projects targeting iOS and macOS. When pub dependencies update, pods also may need to update, which may not be pushed to origin. A CI step can easily handle this:

```sh
if [ -d "ios" ]; then
    flutter pub get
    cd ios
    pod install
    cd ..
    if [[ $(git status -s) ]]; then
      echo "Found uncommitted Podspec.lock changes"
      git status -s
      exit 1
    fi
fi
```

## Tests

As you are a good citizen who write tests, a step can be added to ensure that all tests are passing using:

```sh
flutter test
```

When adding golden tests, be careful that goldens generated on macOS will fail on Linux machines ([open issue](https://github.com/flutter/flutter/issues/56383)). One suggestion is to generate all goldens on Linux (using another workflow or docker), or consider utilizing [alchemist](https://pub.dev/packages/alchemist) which generates goldens for all desktop platforms and ci machine.

## Generated Code

If your project utilizes *freezed* or *json_serializable*, you may wish to add a step which ensures that there are no changes when code is re-generated:

```sh
flutter pub run build_runner build --delete-conflicting-outputs
if git status --porcelain | grep .; then
    git diff
    exit 1
fi
```

## Unused Files

Another step which may be applicable is to ensure that there are no dart files in the project which are currently not used:

```sh
flutter pub global activate dart_code_metrics 5.7.6

OUTPUT=$(flutter pub global run dart_code_metrics:metrics check-unused-files lib)
if [[ OUTPUT ]]; then
    echo "There are unused files"
    echo $OUTPUT
fi
```

Similarly unused code can be tested using `flutter pub global run dart_code_metrics:metrics check-unused-code lib`, while i10n can be tested using `flutter pub global run dart_code_metrics:metrics check-unused-l10n lib`.

Note: As of July 2023, dart_code_metrics is no longer maintained as it is a paid service. More [info](https://dcm.dev/).

