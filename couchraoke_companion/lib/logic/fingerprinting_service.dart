import 'package:couchraoke_companion/src/rust/api/fingerprint.dart';

class FingerprintingService {
  Future<Map<String, String>> generateSignatures(List<String> filePaths) async {
    if (filePaths.isEmpty) {
      return {};
    }

    final results = await getBatchFingerprints(paths: filePaths);
    return {
      for (final result in results) result.path: result.fingerprint,
    };
  }
}
