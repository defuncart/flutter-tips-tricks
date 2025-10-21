# 22 - Fastlane Multiple Flavors

When publishing an app with multiple flavors (i.e. dev, prod) via fastlane to the app stores, it is a good idea to re-use as much common setup as possible.

Consider the following android lane:

```rb
lane :build_deploy_internal do
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

    sh "flutter clean"
    sh "flutter pub get"
    sh "flutter build appbundle"

    upload_to_play_store(
        track: 'internal',
        aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
end
```

which works for a Flutter project with no flavors. Once flavors are added, 1) the package names will differ, 2) the build command will differ (i.e. --flavor) and 3) the output aab filepath will be different.

We could copy & paste this lane for different flavors, however this isn't maintainable when the app should release to multiple tracks and has 2+ flavors.

Instead, we can define a basic config

```rb
configs = {
  dev: {
    package_name: "com.defuncart.app.dev",
    build_command: "--flavor dev",
    aab_filepath: "../build/app/outputs/bundle/devRelease/app-dev-release.aab"
  },
  prod: {
    package_name: "com.defuncart.app",
    build_command: "--flavor prod",
    aab_filepath: "../build/app/outputs/bundle/prodRelease/app-prod-release.aab"
  }
}
```

and a private lane which builds the app for a given config

```rb
private_lane :build_internal do |config|
    previous_alpha_build_number = google_play_track_version_codes(
        package_name: config[:package_name],
        track: 'internal',
    ).max || 0
    previous_prod_build_number = google_play_track_version_codes(
        package_name: config[:package_name],
        track: "production",
    ).max || 0

    current_build_number = [previous_alpha_build_number, previous_prod_build_number].max + 1

    increment_version_code(
        gradle_file_path: "./app/build.gradle.kts",
        version_code: current_build_number
    )

    sh "flutter clean"
    sh "flutter pub get"
    sh "flutter build appbundle #{config[:build_command]}"

    upload_to_play_store(
        package_name: config[:package_name],
        track: 'internal',
        aab: config[:aab_filepath],
    )
end
```

Now multiple lanes can be defined to use this private lane:

```rb
lane :dev_internal do
    build_internal(**configs[:dev])
end

lane :prod_internal do
    build_internal(**configs[:prod])
end
```

This simple template could also be extended to, for instance, automatically release internal builds but mark production builds as draft etc. Moreover, a similar approach can be used for iOS builds.
