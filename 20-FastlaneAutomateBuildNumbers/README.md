# 20 - Fastlane Automate Build Numbers

[fastlane](https://fastlane.tools/) is a CD tool that helps automate uploading binaries to the app stores.

## Basic Setup

Refer to the [documentation](https://docs.fastlane.tools/) for complete setup information. Assuming that both Android and iOS have Appfile, Fastfile, and that iOS uses `match`, building & distribution is as simple as follows:

### Android

```rb
# android/fastlane/Fastfile
lane :build_upload_internal do
    sh "flutter build appbundle"

    upload_to_play_store(
        track: 'internal',
        aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
end
```

### iOS

```rb
# ios/fastlane/Fastfile
lane :build_upload do
    setup_ci

    match(type: 'appstore', readonly: is_ci)

    app_store_connect_api_key(
        is_key_content_base64: true
    )

    build_app(
        workspace: "Runner.xcworkspace",
        scheme: "Runner",
        configuration: "Release",
        export_method: "app-store"
    )

    upload_to_testflight
end
```

## Build Numbers

Unique build numbers can be set manually in `pubspec.yaml` as follows:

```yaml
version: 1.2.3+99
```

where the build number (99) is specified after the +. This, however, is repetitive and error prone. As app stores require unique build numbers, when an app version is distributed with a previously used build number, the upload will fail, breaking distribution.

In the following approach, a fixed build number (1) will always be used in pubspec.yaml, with the actual build number overridden during the build process using Fastlane.

### Android

Google Play expects a unique version code (i.e. build number) for each app version uploaded. The fastlane plugin [increment_version_code](https://github.com/Jems22/fastlane-plugin-increment_version_code) helps automate this by retrieving the latest version codes from Google Play. Install it in `android` folder as follows:

```sh
fastlane add_plugin increment_version_code
```

Google Play has a couple of different tracks: `internal`, `closed`, `open` and `production`. Regardless of track, each app upload requires a unique version code. Each track can also have multiple active builds, for instance staged releases.

Thus, to correctly determine the next version code, you need to get the current version codes on all relevant tracks, determine the largest and increment. In the case of internal track and production, add the following lane:

```rb
# android/fastlane/Fastfile
lane :increment_android_build_number do
    previous_alpha_build_number = google_play_track_version_codes(
        track: "internal",
    ).max || 0
    previous_prod_build_number = google_play_track_version_codes(
        track: "production",
    ).max || 0

    current_build_number = [previous_alpha_build_number, previous_prod_build_number].max + 1

    increment_version_code(
        gradle_file_path: "./app/build.gradle.kts",
        version_code: current_build_number
    )
end
```

and run it before building the app.

Tip: Ensure that `versionCode = 1` is set in `app/build.gradle.kts` so that the version code can be overwritten.

### iOS

On iOS, the process is easier. As all builds first need to be uploaded to TestFlight anyway, we can simply grab the latest build number and increment it. Simply add `increment_build_number` before `build_app`:

```rb
# ios/fastlane/Fastfile
increment_build_number(
    build_number: latest_testflight_build_number + 1,
    xcodeproj: "Runner.xcodeproj"
)
```

## Concurrent Builds

When automating build numbers, you will want to avoid concurrent builds. 

Consider that on merge to main, new internal Android and TestFlight iOS builds are triggered. If two merges to main happen within a short time frame (eg 15 minutes), the second build might start before the first finishes. This can cause both builds to have the same build number, leading to upload rejection by the stores and breaking the deployment process.

Set up your CD pipeline so that in-progress builds are cancelled when a new one starts.
