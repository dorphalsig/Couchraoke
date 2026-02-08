use hound::{SampleFormat, WavReader};
use pyin_rs::pyin::{AudioAnalyzer, PitchConfig};
use rand::{rngs::StdRng, Rng, SeedableRng};
use std::fs::File;
use std::io::BufReader;
use std::path::Path;

fn stream_collect(bytes: &[u8], sample_rate_hz: u32, window_ms: u32, hop_ms: u32) -> Vec<u16> {
    let mut analyzer = AudioAnalyzer::new(PitchConfig {
        sample_rate_hz,
        update_interval_ms: hop_ms,
        window_size_ms: window_ms,
    })
    .expect("create audio analyzer");
    let mut rng = StdRng::seed_from_u64(7);
    let mut mids = Vec::new();
    let mut offset = 0usize;
    while offset < bytes.len() {
        let n = rng.gen_range(1..4096).min(bytes.len() - offset);
        let chunk = &bytes[offset..offset + n];
        let events = analyzer.process_chunk_collect(chunk).expect("process chunk");
        mids.extend(events.into_iter().map(u16::from));
        offset += n;
    }
    mids
}

fn mode(values: &[u16]) -> Option<u16> {
    let mut counts = std::collections::BTreeMap::<u16, usize>::new();
    for &v in values {
        *counts.entry(v).or_default() += 1;
    }
    counts.into_iter().max_by_key(|(_, c)| *c).map(|(v, _)| v)
}

#[test]
fn wav_fixtures_expected_modes() {
    const EXPECTED_SAMPLE_RATE_HZ: u32 = 44_100;
    let fixtures = [
        ("fixtures/F2_87Hz.wav", 41),
        ("fixtures/A#2_116Hz.wav", 46),
        ("fixtures/B2_123Hz.wav", 47),
        ("fixtures/C4_261Hz.wav", 60),
        ("fixtures/C#4_277Hz.wav", 61),
        ("fixtures/D4_293Hz.wav", 62),
        ("fixtures/E4_329Hz.wav", 64),
        ("fixtures/F#4_369Hz.wav", 66),
        ("fixtures/G#4_415Hz.wav", 68),
        ("fixtures/B4_493Hz.wav", 71),
    ];

    for (path, expected) in fixtures {
        let (bytes, sample_rate_hz) = read_wav_pcm16le(Path::new(path));
        assert_eq!(
            sample_rate_hz, EXPECTED_SAMPLE_RATE_HZ,
            "fixture {} sample rate mismatch",
            path
        );
        let (window_ms, hop_ms) = (43, 5);
        let mut voiced = stream_collect(&bytes, sample_rate_hz, window_ms, hop_ms);
        assert!(voiced.len() >= 10, "{} had insufficient voiced outputs", path);
        voiced.drain(0..voiced.len().min(3));
        let m = mode(&voiced).expect("mode exists");
        assert_eq!(m, expected, "fixture {} mode was {}", path, m);
    }
}

fn read_wav_pcm16le(path: &Path) -> (Vec<u8>, u32) {
    let reader = WavReader::new(BufReader::new(File::open(path).expect("open wav fixture")))
        .expect("read wav header");
    let spec = reader.spec();
    let sample_rate_hz = spec.sample_rate;
    let channels = spec.channels as usize;
    let mut bytes = Vec::new();
    match spec.sample_format {
        SampleFormat::Int => {
            for (idx, sample) in reader
                .into_samples::<i16>()
                .map(|s| s.expect("read wav sample"))
                .enumerate()
            {
                if channels > 1 && idx % channels != 0 {
                    continue;
                }
                bytes.extend_from_slice(&sample.to_le_bytes());
            }
        }
        SampleFormat::Float => {
            for (idx, sample) in reader
                .into_samples::<f32>()
                .map(|s| s.expect("read wav sample"))
                .enumerate()
            {
                if channels > 1 && idx % channels != 0 {
                    continue;
                }
                let clamped = (sample * 32767.0).clamp(-32768.0, 32767.0) as i16;
                bytes.extend_from_slice(&clamped.to_le_bytes());
            }
        }
    }
    (bytes, sample_rate_hz)
}
