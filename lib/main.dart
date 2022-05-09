import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_try/app_info.dart';

final buttonIdProvider = StateProvider((ref) => -1);

void main() {
  runApp(const ProviderScope(child: TopPage()));
}

class TopPage extends ConsumerWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var buttonId = ref.watch(buttonIdProvider);
    return MaterialApp(
      home: Navigator(
        pages: [
          const MaterialPage(child: MenuPage()),
          if (buttonId == 0) MaterialPage(child: MyHomePage()),
          if (buttonId == 1) MaterialPage(child: MyHomePage()),
          if (buttonId == 2) MaterialPage(child: MyHomePage()),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }
          ref.read(buttonIdProvider.state).state = -1;
          return true;
        },
      ),
    );
  }
}

class MenuPage extends ConsumerWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> titles = ['a', 'b'];
    return Scaffold(
      appBar: AppBar(),
      body: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          children: List.generate(titles.length, (index) {
            return TaskContent(index, titles);
          })),
    );
  }
}

class TaskContent extends ConsumerWidget {
  TaskContent(this.index, this.titles);
  double taskSpacing = 12.0;
  int index;
  List<String> titles;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double taskSize =
        (MediaQuery.of(context).size.shortestSide - taskSpacing) / 2;
    void changeState() {
      ref.read(buttonIdProvider.state).state = index;
    }

    return InkWell(
      onTap: changeState,
      child: Padding(
        padding: EdgeInsets.all(taskSpacing / 2),
        child: Container(
          alignment: Alignment.center,
          width: taskSize - taskSpacing,
          height: taskSize - taskSpacing,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.pink[100],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(titles[index],
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 17)),
                const Text('これ'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    getAppVersion();
  }
  String _appVersion = '';

  Future<void> getAppVersion() async {
    String appVersion;
    try {
      appVersion = await AppInfo.appVersion ?? 'Unknown App version';
    } on PlatformException {
      appVersion = 'Failed app version';
    }
    setState(() {
      _appVersion = appVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Text(_appVersion, style: const TextStyle(fontSize: 20))),
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}
