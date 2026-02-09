use pyin_rs::fingerprint::get_batch_fingerprints;
use std::path::Path;

#[test]
fn fingerprints_for_mp3_and_ogg_are_generated() {
    let manifest_dir = Path::new(env!("CARGO_MANIFEST_DIR"));
    let mp3_path = manifest_dir
        .join("fixtures/chromaprint/Going-Different-Ways_Remixed.mp3");
    let ogg_path = manifest_dir.join("fixtures/chromaprint/The Biggest Discovery.ogg");

    let results = get_batch_fingerprints(vec![
        mp3_path.to_string_lossy().to_string(),
        ogg_path.to_string_lossy().to_string(),
    ]);

    assert_eq!(results.len(), 2);
    for result in results {
        assert!(
            !result.fingerprint.is_empty(),
            "Fingerprint should not be empty for {}",
            result.path
        );
    }
}
