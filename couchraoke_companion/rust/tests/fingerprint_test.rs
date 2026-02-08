use pyin_rs::fingerprint::get_batch_fingerprints;
use std::path::PathBuf;

#[test]
fn test_mp3_fingerprint() {
    let mut path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    path.push("fixtures/chromaprint/Going-Different-Ways_Remixed.mp3");

    let results = get_batch_fingerprints(vec![path.to_str().unwrap().to_string()]);
    assert_eq!(results.len(), 1);
    assert!(
        !results[0].fingerprint.is_empty(),
        "MP3 Fingerprint should not be empty"
    );
}

#[test]
fn test_ogg_fingerprint() {
    let mut path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    path.push("fixtures/chromaprint/The Biggest Discovery.ogg");

    let results = get_batch_fingerprints(vec![path.to_str().unwrap().to_string()]);
    assert_eq!(results.len(), 1);
    assert!(
        !results[0].fingerprint.is_empty(),
        "OGG Fingerprint should not be empty"
    );
}
