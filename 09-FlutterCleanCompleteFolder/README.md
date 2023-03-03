# 09 - Flutter Clean Multiple Projects

Consider that you have, for instance, a mono-repository in which multiple apps depend on multiple internal packages:

```
monorepo/
├─ apps/
│  ├─ app1/
│  ├─ app2/
├─ packages/
│  ├─ package1
│  ├─ package2
├─ README.md
```

or a folder of personal projects:

```
my-projects/
├─ app1/
├─ app2/
```

and you want to run `flutter clean` in each sub-folder. Running this command from the root folder will not do anything as the command expects to be run from a dart/flutter project.

One solution is to add a simple script to root:

```sh
#!/bin/bash

# script to delete the build folders of all project sub-folders
find  `pwd` -type d -maxdepth 1 | while read dir; do
    if [ -f "$dir/pubspec.yaml" ]; then
        cd $dir
        echo $(pwd)
        flutter clean
        cd -
    fi
done
```

and execute it in the terminal. `maxdepth` can also be a dynamically parameter, if required.

This is a handy way to free up some hard drive space, or do a deep clean in a monorepo.
