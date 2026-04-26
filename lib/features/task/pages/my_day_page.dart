import 'package:flutter/material.dart';

class MyDayPage extends StatefulWidget {
  const MyDayPage({super.key});

  @override
  State<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [Text('My Day')]));
  }
}
