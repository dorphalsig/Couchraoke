use base64::engine::general_purpose;
use base64::Engine;
use log::error;
use rayon::prelude::*;
use rusty_chromaprint::{Configuration, FingerprintCompressor, Fingerprinter};
use symphonia::core::audio::SampleBuffer;
use symphonia::core::codecs::DecoderOptions;
use symphonia::core::errors::Error;
use symphonia::core::formats::FormatOptions;
use symphonia::core::io::MediaSourceStream;
use symphonia::core::meta::MetadataOptions;
use symphonia::core::probe::Hint;

pub struct AudioFingerprint {
    pub path: String,
    pub fingerprint: String,
    pub duration_secs: f64,
}

pub fn get_batch_fingerprints(paths: Vec<String>) -> Vec<AudioFingerprint> {
    paths
        .par_iter()
        .map(|path| match fingerprint_path(path) {
            Ok(data) => data,
            Err(err) => {
                error!("Failed to fingerprint {}: {}", path, err);
                AudioFingerprint {
                    path: path.clone(),
                    fingerprint: String::new(),
                    duration_secs: 0.0,
                }
            }
        })
        .collect()
}

fn fingerprint_path(path: &str) -> anyhow::Result<AudioFingerprint> {
    let file = std::fs::File::open(path)?;
    let mss = MediaSourceStream::new(Box::new(file), Default::default());

    let mut hint = Hint::new();
    if let Some(ext) = std::path::Path::new(path)
        .extension()
        .and_then(|ext| ext.to_str())
    {
        hint.with_extension(ext);
    }

    let probed = symphonia::default::get_probe().format(
        &hint,
        mss,
        &FormatOptions::default(),
        &MetadataOptions::default(),
    )?;

    let mut format = probed.format;
    let (track_id, codec_params, sample_rate, channels) = {
        let track = format
            .default_track()
            .ok_or_else(|| anyhow::anyhow!("no default track found"))?;
        let codec_params = track.codec_params.clone();
        let sample_rate = codec_params
            .sample_rate
            .ok_or_else(|| anyhow::anyhow!("missing sample rate"))?;
        let channels = codec_params
            .channels
            .ok_or_else(|| anyhow::anyhow!("missing channel information"))?
            .count();
        (track.id, codec_params, sample_rate, channels)
    };

    let mut decoder = symphonia::default::get_codecs()
        .make(&codec_params, &DecoderOptions::default())?;

    let config = Configuration::preset_test1();
    let mut fingerprinter = Fingerprinter::new(&config);
    fingerprinter.start(sample_rate, channels as u32)?;

    let mut total_frames: u64 = 0;

    loop {
        let packet = match format.next_packet() {
            Ok(packet) => packet,
            Err(Error::IoError(err)) if err.kind() == std::io::ErrorKind::UnexpectedEof => break,
            Err(err) => return Err(err.into()),
        };

        if packet.track_id() != track_id {
            continue;
        }

        let decoded = match decoder.decode(&packet) {
            Ok(decoded) => decoded,
            Err(Error::DecodeError(err)) => {
                error!("Decode error in {}: {}", path, err);
                continue;
            }
            Err(err) => return Err(err.into()),
        };

        let frame_count = decoded.frames() as u64;
        let spec = *decoded.spec();
        let mut sample_buffer = SampleBuffer::<i16>::new(decoded.capacity() as u64, spec);
        sample_buffer.copy_interleaved_ref(decoded);
        fingerprinter.consume(sample_buffer.samples());

        total_frames += frame_count;
    }

    fingerprinter.finish();
    let fingerprint = fingerprinter.fingerprint();
    if fingerprint.is_empty() {
        return Err(anyhow::anyhow!("fingerprint generation failed"));
    }
    let compressor = FingerprintCompressor::from(&config);
    let compressed = compressor.compress(fingerprint);
    let fingerprint = general_purpose::STANDARD.encode(compressed);
    let duration_secs = total_frames as f64 / sample_rate as f64;

    Ok(AudioFingerprint {
        path: path.to_string(),
        fingerprint,
        duration_secs,
    })
}
