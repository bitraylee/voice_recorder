import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'audioPlayer.dart';

class VoiceRecorder extends StatefulWidget {
  const VoiceRecorder({Key? key, required this.title}) : super(key: key);
  final String title;

  State<VoiceRecorder> createState() => _VoiceRecorder();
}

class _VoiceRecorder extends State<VoiceRecorder> {
  final recorder = FlutterSoundRecorder();
  String _fileName = "";
  final String _fileExtension = '.mp3';
  // final String _directoryPath=;
  final String _directoryPath = "";
  bool isRecorderReady = false;

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

  Future<String> _generateFileName() async {
    _fileName = 'recording_' + DateTime.now().toString();
    return _directoryPath + "/" + _fileName + _fileExtension;
  }

  // void _createFile() async{
  //   var _completeFileName=await _generateFileName();
  //   File(_completeFileName).create(recursive: true).then(File file)
  // }
  // Future<bool> _requestPermission(Permission perm) async{
  //   final status=perm.request();
  //   if(status!=PermissionStatus.granted){
  //     return false;
  //     // throw "Permission is not granted";
  //   }
  //   return true;
  // }
  /*Future<void> _createDirectory(String _directoryPath) async {
    bool isCreated = await Directory(_directoryPath).exists();
    if (!isCreated && await _hasAcceptedPermissions()) {
      Directory(_directoryPath)
          .create()
          .then((Directory dir) => {print(dir.path)});
    }
  }*/

  Future<bool> _hasAcceptedPermissions() async {
    final storagePerm = await Permission.storage.request();
    final mediaPerm = await Permission.accessMediaLocation.request();
    final extStoragePerm = await Permission.manageExternalStorage.request();

    if (storagePerm == PermissionStatus.granted &&
        mediaPerm == PermissionStatus.granted &&
        extStoragePerm == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  // void _writeFileToStorage() async{
  //   _createDirectory();
  //   _createFile();
  // }
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
      //TODO: Resolve the path error
      // final audioFile = File('$currentDir/${DateTime.now()}.mp3');
      final audioFile = File(recordedAudio!);
      print('saved in ${audioFile.path}');
      //TODO: Make simple navigation to the audio recorder with the recorded audio path;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayRecorded(recordedFile: audioFile),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white));
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            child:
                Icon(recorder.isRecording ? Icons.stop : Icons.mic, size: 40),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return Colors.white30;
                    return Colors.white10; // Use the component's default.
                  },
                ),
                padding: MaterialStateProperty.resolveWith<EdgeInsets?>(
                    (Set<MaterialState> states) {
                  return EdgeInsets.fromLTRB(
                      20, 20, 20, 20); // Use the component's default.
                }),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  //side: BorderSide(color: Colors.red)
                ))),
            onPressed: () async {
              if (recorder.isRecording) {
                await stop();
              } else {
                await record();
              }
              setState(() {});
            },
          )
        ],
      )),
    );
  }
}
