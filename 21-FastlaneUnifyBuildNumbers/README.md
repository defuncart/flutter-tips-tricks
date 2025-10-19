# 21 - Fastlane Unify Build Numbers

When automating builds, Android and iOS build numbers may fall out of sync due to failed uploads. Although using the same build number for the same app release across platforms is not required for all teams, a unified number can help cross-platform debugging from crash reports as build 1.2.3(99) is not just unique but refers to identical code point for both Android and iOS apps.

## Approach

In order to determine a unified build number, we need to determine the current overall highest version code used on all tracks on Google Play, and the highest build number on TestFlight. Then we can simply increment and pass this value onto the build jobs themselves. 

Note: Fastlane is written in Ruby, and each lane is a Ruby method that can return values. However, in multi-step CI jobs, it’s often more reliable to pass values like build numbers via intermediate files. Depending on CD pipeline setup, environment variables,  parameters or job outputs could also be used.

### Android

In `android/fastlane/Fastfile` add a lane which saves the current highest version code to `android/build_number.txt`:

```rb
lane :get_android_build_number do
    previous_alpha_build_number = google_play_track_version_codes(
        track: "internal",
    ).max || 0
    previous_prod_build_number = google_play_track_version_codes(
        track: "production",
    ).max || 0

    current_build_number = [previous_alpha_build_number, previous_prod_build_number].max

    # current folder is fastlane, save file in android
    File.write("../build_number.txt", current_build_number.to_s)
end
```

and another lane which can set the version code:

```rb
lane :set_build_num do |options|
    build_number = options[:build_number]

    increment_version_code(
        gradle_file_path: "./app/build.gradle.kts",
        version_code: build_number
    )
end
```

### iOS

In `ios/fastlane/Fastfile` add a lane which saves the current highest version code to `ios/build_number.txt`:

```rb
lane :get_ios_build_number do
    app_store_connect_api_key(
      is_key_content_base64: true
    )
    build_number = latest_testflight_build_number
    # current folder is fastlane, save file in ios
    File.write("../build_number.txt", build_number.to_s)
end
```

and update the distribution lane to set this build number:

```rb
lane :deploy do |options|
    build_number = options[:build_number]

    increment_build_number(
        build_number: build_number,
        xcodeproj: "Runner.xcodeproj"
    )
end
```

### Unified Script

Now, we can either utilize Fastlane itself by adding `fastlane/Fastfile` to the root of the project 

```rb
# fastlane/Fastfile
lane :get_max_build_number do
  # current path is fastlane, move to root
  android_build = File.read("../android/build_number.txt").strip.to_i rescue 0
  ios_build = File.read("../ios/build_number.txt").strip.to_i rescue 0

  max_build = [android_build, ios_build].max + 1

  # current folder is fastlane, save file in root
  File.write("../build_number.txt", max_build)
end
```

or a simple bash script `scripts/get_max_build_number.sh`

```sh
#!/bin/bash

ANDROID_BUILD=$(cat android/build_number.txt)
IOS_BUILD=$(cat ios/build_number.txt)

# parse as numbers
ANDROID_BUILD=${ANDROID_BUILD:-0}
IOS_BUILD=${IOS_BUILD:-0}

MAX_BUILD=$((ANDROID_BUILD > IOS_BUILD ? ANDROID_BUILD : IOS_BUILD))
NEXT_BUILD=$((MAX_BUILD + 1))

echo "$NEXT_BUILD" > build_number.txt
```

to save the new, unified build number to `build_number.txt` in project root.

### CD Pipeline

As Android and iOS build jobs generally run in parallel, it is a good idea to determine this new, unified build number first, and then build the app in subsequent job.

#### Preparation

Assuming all secrets, keys etc. are injected, determine the largest Android version code, iOS build number, and then increment and to `build_number.txt`.

```sh
cd android && fastlane get_android_build_number && cd ..
cd ios && fastlane get_ios_build_number && cd ..

# root fastlane/fastfile
fastlane get_max_build_number

# or bash script
sh scripts/get_max_build_number.sh
```

#### Build

In the next job, read in the build number, pass this to the build lanes and build & deploy the app:

```sh
BUILD_NUMBER=$(cat build_number.txt)

# android
cd android && fastlane set_build_num build_number:$BUILD_NUMBER && cd ..
flutter build appbundle
cd android && fastlane internal

# ios
cd ios && fastlane deploy build_number:$BUILD_NUMBER
```

Now both iOS and Android builds will have identical build numbers.
