---
name: Bug report
about: Create a report to help me improve
title: ''
labels: bug
assignees: afonsocraposo

---

# Bug Report

## Description

[Provide a clear and concise description of the bug you encountered.]

## Steps to Reproduce

1. [Outline the steps to reproduce the bug. Be specific and provide any necessary context or prerequisites.]
2. [Add additional steps if necessary.]

## Expected Behavior

[Describe what you expected to happen.]

## Actual Behavior

[Describe what actually happened.]

## Additional Information

[Provide any additional information that may be helpful in understanding and reproducing the issue.]

## Code Example

[Provide a minimal, complete, and verifiable example that reproduces the issue. Use code blocks to preserve the formatting.]

```dart
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Example(),
    );
  }
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: <Widget>[
              ButtonsTabBar(
                tabs: const [
                  Tab(
                    icon: Icon(Icons.directions_car),
                    text: "car",
                  ),
                  Tab(
                    icon: Icon(Icons.directions_transit),
                    text: "transit",
                  ),
                  Tab(icon: Icon(Icons.directions_bike)),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: <Widget>[
                    Center(
                      child: Icon(Icons.directions_car),
                    ),
                    Center(
                      child: Icon(Icons.directions_transit),
                    ),
                    Center(
                      child: Icon(Icons.directions_bike),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Please make sure to include a working example code that can reproduce the bug.** You can use the provided code snippet as a starting point.

Thank you for reporting this bug! We appreciate your contribution to improving our Flutter package.
