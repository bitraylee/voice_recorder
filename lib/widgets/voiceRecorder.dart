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
                  const Text(
                    "Recording 1",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
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
                  IconButton(
                    icon: Icon(
                      recorder.isRecording
                          ? Icons.stop
                          : Icons.mic,
                    ),
                    iconSize: 30,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
