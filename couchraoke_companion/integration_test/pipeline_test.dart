import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wav/wav.dart';

import 'package:couchraoke_companion/src/rust/api/frb_generated.dart';
import 'package:couchraoke_companion/src/rust/api/pyin/api.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testFile = 'C4_261Hz.wav';
  const expectedMidi = 60;

  setUpAll(() async {
    await RustLib.init();
  });

  testWidgets('Pipeline Test: Stream WAV to Rust and verify MIDI output',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      // 1. Load Asset
      final ByteData fileData =
          await rootBundle.load('rust/fixtures/$testFile');

      // 2. Decode WAV & Convert to PCM
      final wav = Wav.read(fileData.buffer.asUint8List());
      final pcmBytes = _floatToPcm16(wav.channels.first);

      // 3. Initialize Engine
      final config = PitchConfig(
        sampleRateHz: wav.samplesPerSecond,
        updateIntervalMs: 30,
        windowSizeMs: 50,
      );

      final analyzer = await AudioAnalyzer.newInstance(config: config);

      final emittedNotes = <int>[];

      // 4. Stream Simulation
      const chunkSize = 2048;

      final pending = <Future<Uint8List>>[];
      for (var i = 0; i < pcmBytes.length; i += chunkSize) {
        final end = (i + chunkSize < pcmBytes.length)
            ? i + chunkSize
            : pcmBytes.length;
        final chunk = pcmBytes.sublist(i, end);

        pending.add(analyzer.processChunkCollect(pcm16LeBytes: chunk));
      }

      final collected = await Future.wait(pending)
          .timeout(const Duration(seconds: 5), onTimeout: () => <Uint8List>[]);
      for (final chunkNotes in collected) {
        for (final note in chunkNotes) {
          if (note != 255) emittedNotes.add(note);
        }
      }

      // 5. Assertions
      expect(emittedNotes, isNotEmpty,
          reason: 'Pipeline failed: No events emitted');

      final mode = _calculateMode(emittedNotes);
      expect(mode, equals(expectedMidi), reason: 'Pitch mismatch');
    });
  });
}

Uint8List _floatToPcm16(List<double> floats) {
  final buffer = ByteData(floats.length * 2);
  for (var i = 0; i < floats.length; i++) {
    var sample = floats[i];
    if (sample < -1.0) sample = -1.0;
    if (sample > 1.0) sample = 1.0;
    final val = (sample * 32767).round();
    buffer.setInt16(i * 2, val, Endian.little);
  }
  return buffer.buffer.asUint8List();
}

int _calculateMode(List<int> list) {
  if (list.isEmpty) return -1;
  final counts = <int, int>{};
  for (final item in list) {
    counts[item] = (counts[item] ?? 0) + 1;
  }
  return counts.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
}
