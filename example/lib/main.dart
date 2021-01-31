import 'package:automatic_spring_animation/automatic_spring_animation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        showPerformanceOverlay: false,
        themeMode: ThemeMode.system,
        darkTheme: ThemeData.dark(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomeScreen());
  }
}

class MyHomeScreen extends StatefulWidget {
  MyHomeScreen({Key? key}) : super(key: key);

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  Alignment _align = Alignment.center;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: _align,
            child: AnimtedSpring(
              child: GestureDetector(
                onTap: () {
                  print("tap");
                },
                child: Container(
                  color: Colors.amberAccent,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
        ),
        ButtonBar(
          children: [
            ElevatedButton(
              child: Text("Center"),
              onPressed: () {
                setState(() {
                  _align = Alignment.center;
                });
              },
            ),
            ElevatedButton(
              child: Text("Top Left"),
              onPressed: () {
                setState(() {
                  _align = Alignment.topLeft;
                });
              },
            ),
            ElevatedButton(
              child: Text("Top Right"),
              onPressed: () {
                setState(() {
                  _align = Alignment.topRight;
                });
              },
            ),
            ElevatedButton(
              child: Text("Bottom Left"),
              onPressed: () {
                setState(() {
                  _align = Alignment.bottomLeft;
                });
              },
            ),
            ElevatedButton(
              child: Text("Bottom Right"),
              onPressed: () {
                setState(() {
                  _align = Alignment.bottomRight;
                });
              },
            )
          ],
        ),
      ],
    );
  }
}
