import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';



class PlayRecorded extends StatefulWidget{
  const PlayRecorded({Key?key, required this.title}):super(key:key);
  final String title;
  State<PlayRecorded> createState()=> _PlayRecorded();
}

class _PlayRecorded extends State<PlayRecorded>{
  final audioPlayer= AudioPlayer();
  bool isPlaying=false;
  Duration duration= Duration.zero;
  Duration position= Duration.zero;

  String formatTime(Duration duration){
    String twoDigits(int n)=>n.toString().padLeft(2,'0');
    final hours=twoDigits(duration.inHours);
    final minutes=twoDigits(duration.inMinutes.remainder(60));
    final seconds=twoDigits(duration.inSeconds.remainder(60));

    return [
      if(duration.inHours>0) hours,
      minutes,
      seconds,
    ].join(':');
  }
  @override
  void initState(){
    super.initState();
    //playing, paused, stopped
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying= (state==PlayerState.playing);
      });
    });

    //audio duration
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration=newDuration;
      });
    });

    //audio position
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState((){
        position=newPosition;
      });
    });

  }
  @override
  void dispose(){
    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context)=> Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recording 1",
                        style:TextStyle(
                            fontSize:18,
                            color: Colors.black54
                        )
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying? Icons.pause_rounded: Icons.play_arrow_rounded,
                      ),
                      iconSize: 30,
                      onPressed: () async{
                        if(isPlaying){
                          await audioPlayer.pause();
                        }else {
                          String url="https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";

                          audioPlayer.setSourceUrl(url);
                          audioPlayer.resume();
                          print(audioPlayer);
                        }
                      },
                    )
                  ],
                ),
              ),
              Slider(
                  min:0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged:(value) async{}
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatTime(position),
                        style:TextStyle(
                            fontSize:14,
                            color: Colors.black54
                        )
                    ),
                    Text(formatTime(duration-position),
                        style:TextStyle(
                            fontSize:14,
                            color: Colors.black54
                        )
                    )
                  ],
                )
              ),

            ],
          )
      )
  );

}
