import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'src/rust/api/frb_generated.dart';
import 'src/rust/api/pyin/api.dart';

class PitchDetectorController with WidgetsBindingObserver {
  final AudioRecorder _recorder = AudioRecorder();
  AudioAnalyzer? _analyzer;

  // State to track if the user WANTS to be recording,
  // distinct from whether the mic is actually open (OS lifecycle).
  bool _isRecordingIntent = false;

  // Cache config to restart recorder on resume
  PitchConfig? _lastConfig;

  Stream<int>? _noteStream;
  StreamSubscription<List<int>>? _micSubscription;

  PitchDetectorController() {
    WidgetsBinding.instance.addObserver(this);
  }

  Stream<int>? get noteStream => _noteStream;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _micSubscription?.cancel();
      _micSubscription = null;
      _recorder.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (_isRecordingIntent && _lastConfig != null) {
        _startMicrophone(_lastConfig!);
      }
    }
  }

  Future<void> start(PitchConfig config) async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission denied');
    }

    await RustLib.init();
    _analyzer = await AudioAnalyzer.newInstance(config: config);
    _noteStream = _analyzer!.createStream();

    _lastConfig = config;
    _isRecordingIntent = true;

    await _startMicrophone(config);
  }

  Future<void> _startMicrophone(PitchConfig config) async {
    if (await _recorder.isRecording()) return;

    final stream = await _recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: config.sampleRateHz,
        numChannels: 1,
      ),
    );

    _micSubscription?.cancel();
    _micSubscription = stream.listen((data) {
      _analyzer?.processChunk(pcm16LeBytes: data);
    });
  }

  Future<void> stop() async {
    _isRecordingIntent = false;
    _micSubscription?.cancel();
    _micSubscription = null;
    await _recorder.stop();
    _analyzer = null;
    _lastConfig = null;
    _noteStream = null;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _micSubscription?.cancel();
    _recorder.dispose();
  }
}
