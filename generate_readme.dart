import 'dart:io';

void main() {
  final sb = StringBuffer('''
# Flutter Tips 'n' Tricks

A collection of tips 'n' tricks for Flutter, Dart and Mobile/Web/Desktop Development.

| Tips |
|------|
''');

  final paths = _foldersInCurrentDirectory(foldersToIgnore: ['.git']);
  for (final path in paths) {
    final tipName = path.split('-').last.split(RegExp(r"(?=(?!^)[A-Z\(])")).join(' ');
    final link = 'https://github.com/defuncart/flutter-tips-tricks/blob/master/$path/README.md';

    sb.writeln('| [$tipName]($link) |');
  }
  sb.writeln('');
  sb.writeln('Spotted any mistakes? Please file an [issue](https://github.com/defuncart/flutter-tips-tricks/issues)!');

  File('README.md').writeAsStringSync(sb.toString());
}

List<String> _foldersInCurrentDirectory({List<String>? foldersToIgnore}) {
  final dir = Directory.current;
  if (!dir.existsSync()) {
    print('Folder ${Directory.current} does not exist');
    exit(1);
  }

  final subFolders = dir
      .listSync()
      .whereType<Directory>()
      .map((folder) => folder.path)
      .map((folder) => folder.replaceFirst('${Directory.current.path}/', ''))
      .toList();
  if (foldersToIgnore?.isNotEmpty == true) {
    foldersToIgnore!.forEach((folder) => subFolders.remove(folder));
  }
  subFolders.sort((a, b) => b.compareTo(a));
  return subFolders;
}
