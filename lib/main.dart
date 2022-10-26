// import 'dart:html';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voice_recorder/widgets/audioPlayer.dart';
import 'package:voice_recorder/widgets/newVoiceRecorder.dart';
import 'package:voice_recorder/widgets/statefulDialog.dart';
import 'package:voice_recorder/widgets/voiceRecorder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: MaterialApp(
        color: Colors.white,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.black54,
            displayColor: Colors.black54
          )
        ),
        // home: const PlayRecorded(title: 'Simple Player'),
        home: PlayRecorded()
      ),
    );
  }
}

