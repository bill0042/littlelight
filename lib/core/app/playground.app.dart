import 'package:flutter/material.dart';

class Playground extends StatelessWidget {
  final Key key;
  Playground({this.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Playground',
        home: PlaygroundMainScreen());
  }
}

class PlaygroundMainScreen extends StatefulWidget {
  const PlaygroundMainScreen({Key key}) : super(key: key);

  @override
  _PlaygroundMainScreenState createState() => _PlaygroundMainScreenState();
}

class _PlaygroundMainScreenState extends State<PlaygroundMainScreen> {
  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("manifest provider test")),
        body: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [ElevatedButton(onPressed: () {}, child: Text("Test"))],
            )));
  }
}
