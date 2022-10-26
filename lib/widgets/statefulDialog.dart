// import 'dart:html';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart' as Player;
import 'package:flutter_sound/flutter_sound.dart' as Recorder;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voice_recorder/widgets/newVoiceRecorder.dart';

class statefulDialog extends StatefulWidget{
  @override
  State<statefulDialog> createState()=>_statefulDialog();
}

class _statefulDialog extends State<statefulDialog>{
  String data="";
  @override
  Widget build(BuildContext context){
    void getDataFrom(BuildContext context, Widget page) async {
      final dataFromSecondPage = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ) as String;
      data=dataFromSecondPage;
    }
    return Container(
      color: Colors.white,
      child: Center(
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
            shadowColor: MaterialStateProperty.all(Colors.blueAccent),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
          ),
          onPressed: () {
            getDataFrom(context, VoiceAudio());
          },
          child: Text(
            "Stateful Dialog",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16
            )
          ),
        ),
      ),
    );
  }
}

