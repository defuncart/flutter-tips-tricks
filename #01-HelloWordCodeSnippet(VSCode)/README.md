# 01 - *Hello World* Code Snippet (for VS Code)

When we create a new Flutter project, the standard [*starter app*](https://raw.githubusercontent.com/flutter/website/master/src/_assets/image/tools/android-studio/hot-reload.gif), in which the user can click a button and the onscreen count text is updated, is generated. Although this is a nice introduction to Flutter and hot reloading, I always find myself needing to delete most of this boilerplate code or starting from scratch. Wouldn't it be great if there was someway to easily create an *Hello World* code snippet for **main.dart**?

In VS Code open the *Command Palette* (CMD + SHIFT + P), type "snippets" and select **Preferences: Configure User Snippets**

![](images/01.png)

Lets create a new global dart snippet (saved to/modifies *~Library/Application Support/Code/User/snippets/dart.json*) so that when we type a term (e.g. *hello_world*) and press return, a code snippet will be inserted automatically.

![](images/02.png)

Copy and paste the following snippet declaration:

```json
"Flutter-HelloWorld" : {
	"prefix": "hello_world",
	"body": [
		"import 'package:flutter/material.dart';",
		"",
		"void main() => runApp(MyApp());",
		"",
		"class MyApp extends StatelessWidget {",
			"\t@override",
			"\tWidget build(BuildContext context) {",
				"\t\treturn MaterialApp(",
					"\t\t\ttitle: 'Welcome to Flutter',",
					"\t\t\thome: Scaffold(",
						"\t\t\t\tappBar: AppBar(",
							"\t\t\t\t\ttitle: Text('Welcome to Flutter'),",
						"\t\t\t\t),",
						"\t\t\t\tbody: Center(",
							"\t\t\t\t\tchild: Text('Hello World'),",
						"\t\t\t\t),",
					"\t\t\t),",
				"\t\t);",
			"\t}",
		"}",
		""
	],
	"description": "Flutter: Hello World lib/main.dart."
}
```

Now this snippet can be easily used by typing *hello_world* and entering return within any dart file.

![](images/03.gif)

Note that tabs (\t) are used to properly format the code. Maybe there is an easier way of achieving this, I'm still pretty new to VS Code :)

Although Flutter has some built in code snippets in VS Code (for instance *stless* generates a *StatelessWidget*), consider adding the [Awesome Flutter Snippets](https://marketplace.visualstudio.com/items?itemName=Nash.awesome-flutter-snippets) extension by Nash Ramdial for many more!

For an overview of Flutter key bindings in VS Code take a look [here](https://dartcode.org/docs/key-bindings/), while [this post](https://medium.com/flutter-community/flutter-visual-studio-code-shortcuts-for-fast-and-efficient-development-7235bc6c3b7d) by Ganesh .s.p is a great overview of shortcuts within VS Code for Flutter devs (macOS users can generally substitute CMD for CTRL).
