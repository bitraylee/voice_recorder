// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skywa_framework_widgets/skywa_elevated_button.dart';

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
class VoiceRecorder extends StatefulWidget{
  const VoiceRecorder({Key?key, required this.title}):super(key:key);
  final String title;
  State<VoiceRecorder> createState()=> _VoiceRecorder();
}

class PlayRecorded extends StatefulWidget{
  const PlayRecorded({Key?key, required this.title}):super(key:key);
  final String title;
  State<PlayRecorded> createState()=> _PlayRecorded();
}

class _PlayRecorded extends State<PlayRecorded>{
  @override
  Widget build

}

class _VoiceRecorder extends State<VoiceRecorder> {
  final recorder=FlutterSoundRecorder();
  bool isRecorderReady=false;


  @override
  void initState(){
    super.initState();
    initRecorder();
  }
  @override
  void dispose(){
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final status= await Permission.microphone.request();
    if(status!=PermissionStatus.granted){
      throw "Microphone permission is not granted";
    }
    await recorder.openRecorder();
    isRecorderReady=true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }
  Future record() async{
    if(!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }
  Future stop() async{
    await recorder.stopRecorder();

    final path= await recorder.stopRecorder();
    //final audioFile=File(path);

  }
  @override
  Widget build(BuildContext context)=> Scaffold(
    backgroundColor: Colors.blueGrey,
    body:Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<RecordingDisposition>(
            stream: recorder.onProgress,
            builder: (context, snapshot) {
              final duration= snapshot.hasData
                  ? snapshot.data!.duration
                  : Duration.zero;
              // String twoDigits(int n)=>n.toString().padLeft(30);
              String twoDigits(int n)=>n.toString();
              final twoDigitMinutes= twoDigits(duration.inMinutes.remainder(60));
              final twoDigitSeconds=twoDigits(duration.inSeconds.remainder(60));

              return Text(
                '$twoDigitMinutes:$twoDigitSeconds',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                )
              );
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            child:Icon(
                recorder.isRecording?Icons.stop: Icons.mic,
                size: 40
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed))
                    return Colors.white30;
                  return Colors.white10; // Use the component's default.
                  },
                ),
              padding: MaterialStateProperty.resolveWith<EdgeInsets?>((Set<MaterialState> states) {
                return  EdgeInsets.fromLTRB(20,20,20,20);// Use the component's default.
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      //side: BorderSide(color: Colors.red)
                  )
              )
            ),
            onPressed: () async {
              if(recorder.isRecording){
                await stop();
              }else{
                await record();
              }
              setState(() {

              });
            },
          )
        ],
      )
    ),
  );
}
