# 08 - Flutter Test Logs

One issue that you may stumble across while running tests is that when, for instance, a provider cannot be found, a widget/golden test will fail with hundreds/thousands of lines printed out in the console, actually making it impossible to see what the real problem is. Although `flutter test` does not offer a log option, with bash it is possible to save the output of any program.

```sh
flutter test > logs.txt
```

will write the contents of `flutter test` to `logs.text` (overwriting an existing file, if one exists), while

```sh
flutter test >> logs.txt
```

will append the contents (creating a file if it doesn't exist). In both cases, the output won't be displayed in the terminal itself. To display output in terminal and save to a file, simply use

```sh
flutter test | tee logs.txt
```
