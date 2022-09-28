// import 'dart:html';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:voice_recorder/widgets/audioPlayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlayRecorded(title: 'Simple Player'),
    );
  }
}

