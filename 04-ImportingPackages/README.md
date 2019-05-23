# 04 - Importing Packages

Any package hosted on [*pub.dev*](https://pub.dev/) can be easily imported into a Flutter project by listing it as a dependency in **pubspec.yaml**:

```yaml
dependencies:
    flutter:
        sdk: flutter
    my_package: ^1.0.0
```

However, there may be times when you are not able to publicly publish a package, for instance internal tools for a company. Another situation may be when a package has a recent critical hotfix or new feature, but hasn't been formally released yet.

## Path

A package on a local machine or network drive can be imported as a path:

```yaml
dependencies:
    ...
    my_package:
        path: /Users/me/my_package
```

which may be useful for local development or when part of a wired network. Note that this path may be relative (to the pubspec file).

## Git

A package can be imported directly from a git repo:

```yaml
dependencies:
    ...
    my_package:
        git: git://github.com/user_name/my_package.git
```

This is especially useful when the repo is private, in which case connect to the repo through SSH:

```yaml
dependencies:
    ...
    my_package:
        git: git@github.com:user_name/my_package.git
```

Even specific commits, branches or tags can be imported by using the **ref** argument:

```yaml
dependencies:
    ...
    my_package:
        git:
            url: git://github.com/user_name/my_package.git
            ref: my_new_branch
```

Pub assumes that the package is in the root of the Git repository. To specify a different location in the repo, use the path argument (relative to the repo's root):

```yaml
dependencies:
    ...
    my_package:
        git:
            url: git://github.com/user_name/packages.git
            path: path/to/my_package
```

## Package Server

It is also possible to use your own package server:

```yaml
dependencies:
    ...
    my_package:
        hosted:
            name: my_package
            url: http://my-package-server.com
        version: ^1.0.0
```

## Resources

[Dart: Package Dependencies](https://dart.dev/tools/pub/dependencies)

[Dart: Pub Server](https://github.com/dart-lang/pub_server)
