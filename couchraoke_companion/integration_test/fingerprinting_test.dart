import 'dart:io';

import 'package:couchraoke_companion/logic/fingerprinting_service.dart';
import 'package:couchraoke_companion/src/rust/api/frb_generated.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<String> copyAssetToTemp(String assetName) async {
  final data = await rootBundle.load(assetName);
  final tempDir = await Directory.systemTemp.createTemp('couchraoke_fingerprint');
  final fileName = assetName.split('/').last;
  final tempFile = File('${tempDir.path}/$fileName');
  await tempFile.writeAsBytes(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  return tempFile.path;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FingerprintingService generates signatures for ogg asset',
      (tester) async {
    await RustLib.init();
    final tempPath =
        await copyAssetToTemp('rust/fixtures/chromaprint/The Biggest Discovery.ogg');
    final service = FingerprintingService();

    final results = await service.generateSignatures([tempPath]);

    expect(results.containsKey(tempPath), isTrue);
    expect(results[tempPath], isNotEmpty);
  });
}
