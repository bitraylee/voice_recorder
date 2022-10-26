import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as Player;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart' as Recorder;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecorder extends StatefulWidget {
  const VoiceRecorder({Key? key}) : super(key: key);
  // final String title;

  State<VoiceRecorder> createState() => _VoiceRecorder();
}

class _VoiceRecorder extends State<VoiceRecorder> {
  final recorder = Recorder.FlutterSoundRecorder();
  bool isRecorderReady = false;

  final audioPlayer = Player.AudioPlayer();
  bool isPlaying = false;
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
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }
  Future<void> initPlayer(File recordedFile) async {
    // setAudioFromAssets();
    setAudioFromAudioFile(recordedFile);
    //playing, paused, stopped
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = (state == Player.PlayerState.playing);
      });
    });

    //audio duration
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    //audio position
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

  Future setAudioFromAssets() async {
    final player = Player.AudioCache(prefix: 'assets/music/');
    final url = await player.load('sample_music.mp3');
    audioPlayer.setSourceDeviceFile(url.path);
  }

  Future<void> setAudioFromAudioFile(File recordedFile) async {
    audioPlayer.setSourceUrl(recordedFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.redAccent,
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Recording file name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin:const EdgeInsets.symmetric(vertical: 20),
              child:Row(
                children: [
                  Text(
                    "Recording 1",
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.black87,
                        // fontWeight:FontWeight.bold
                    ),
                    textAlign: TextAlign.start,
                  )
                ],
              )
            ),
            //Player and Recorder button
            Container(
              // color:Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      return Text('$twoDigitMinutes:$twoDigitSeconds',
                          style: const TextStyle(
                              fontSize:18,
                              color: Colors.black54
                          )
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (recorder.isRecording) {
                        await stop();
                      } else {
                        await record();
                      }
                      setState(() {});
                    },
                    child: Icon( //<-- SEE HERE
                      Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(), //<-- SEE HERE
                      padding: EdgeInsets.all(15),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    iconSize: 30,
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                      } else {
                        audioPlayer.resume();
                        //print(audioPlayer);
                      }
                    },
                  )
                ],
              ),
            ),
            //Seekbar
            Container(
              // color:Colors.blueGrey,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              margin:const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
              child:Column(
                  children:[
                    Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await audioPlayer.seek(position);
                          await audioPlayer.resume();
                        }),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatTime(position),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              formatTime(duration - position),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            )
                          ],
                        )
                    ),
                  ]
              )
            ),
          ],
        ),
      ),
    );
  }
}
