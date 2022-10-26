import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart' as Player;
import 'package:flutter_sound/flutter_sound.dart' as Recorder;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceAudio extends StatefulWidget{
  @override
  State<VoiceAudio> createState()=> _VoiceAudio();
}

class _VoiceAudio extends State<VoiceAudio>{
  bool isPlaying=false;
  bool isRecording=false;
  String data="This is the data";
  late File recordedFile;

  final recorder = Recorder.FlutterSoundRecorder();
  bool isRecorderReady = false;
  final audioPlayer = Player.AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
  @override
  void initState(){
    super.initState();
    initRecorder();
  }
  void initPlayer(File audioFile) {
    // super.initState();
    setAudioFromAudioFile(audioFile);
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = (state == Player.PlayerState.playing);
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }
  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw "Microphone permission is not granted";
    }
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }
  Future<void> record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }
  Future<void> stop() async {
    recorder.stopRecorder().then((recordedAudio) async {
      print('recorder stopped: $recordedAudio');
      final audioFile = File(recordedAudio!);
      print('saved in ${audioFile.path}');
      initPlayer(audioFile);
    });
  }
  Future<void> setAudioFromAudioFile(File recordedFile) async {
    audioPlayer.setSourceUrl(recordedFile.path);
  }
  void setIsRecording() async {
    if(!recorder.isRecording){
      await record();
    }else{
      await stop();
    }
    setState(() {
      isRecording=!isRecording;
    });
  }
  void setIsPlaying() async {
    if(!isPlaying && position==duration){
      position=Duration.zero;
      audioPlayer.resume();
    }
    else if (isPlaying) {
      await audioPlayer.pause();
    } else {
      audioPlayer.resume();
    }
    // setState(() {
    //   isPlaying=!isPlaying;
    // });
  }
  void handleBack() async{
    Navigator.pop(context, data);
  }

  Widget build(BuildContext context){
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.transparent)),
          leading: IconButton(
            //TODO: Make the Navigation.pop() method the return the data back
            // to the screen
            onPressed: handleBack,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.black87,
            ),
          ),

        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children:<Widget>[
              //Recorder
              Expanded(
                flex: 5,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(!isRecording)
                          Text("Tap the button to record the memo"),
                        if(isRecording)
                          Text("Tap the button again to stop recording"),

                        ElevatedButton(
                            onPressed: setIsRecording,
                            child: Icon(
                              isRecording?Icons.stop_rounded: Icons.mic,
                              color: Colors.white70,
                              size: 35,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRecording?Colors.redAccent:
                              Colors.blueAccent,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            )
                        ),
                        //StreamBuilder
                        StreamBuilder<RecordingDisposition>(
                          stream: recorder.onProgress,
                          builder: (context, snapshot) {
                            final duration =
                            snapshot.hasData ? snapshot.data!.duration : Duration.zero;
                            // String twoDigits(int n)=>n.toString().padLeft(30);
                            String twoDigits(int n) => n.toString();
                            final twoDigitMinutes =
                            twoDigits(duration.inMinutes.remainder(60));
                            final twoDigitSeconds =
                            twoDigits(duration.inSeconds.remainder(60));
                            return Text('$twoDigitMinutes:$twoDigitSeconds');
                          },
                        )
                      ],
                    ),
                  ),
                )
              ),
              //Player
              Expanded(
                flex: 1,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: setIsPlaying,
                        icon: Icon(
                          isPlaying?Icons.pause_rounded: Icons.play_arrow_rounded,
                          size: 30,
                        )
                      ),
                      Text(
                          '${formatTime(position)}/${formatTime
                          (duration-position)}',
                          style:const TextStyle(
                            fontSize: 12
                          )
                      ),
                      Expanded(
                        flex:5,
                        child: Container(
                          // width: double.maxFinite,
                          child: Slider(
                              min: 0,
                              max: duration.inSeconds.toDouble(),
                              value: position.inSeconds.toDouble(),
                              onChanged: (value) async {
                                final position = Duration(
                                    seconds: value.toInt());
                                await audioPlayer.seek(position);
                                await audioPlayer.resume();
                              }
                          ),
                        )
                      )
                    ],
                  ),
                )

              )
            ],
          ),
        ),
      ),
    );
  }


}
