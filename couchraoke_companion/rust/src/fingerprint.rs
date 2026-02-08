use anyhow::{anyhow, Context, Result};
use rayon::prelude::*;
use rusty_chromaprint::{Configuration, Fingerprinter};
use std::fs::File;
use std::path::Path;
use symphonia::core::audio::SampleBuffer;
use symphonia::core::codecs::{DecoderOptions, CODEC_TYPE_NULL};
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
        .map(|path| match process_single_file(path) {
            Ok(fp) => fp,
            Err(_e) => {
                // Log error (optional) and return empty fingerprint
                AudioFingerprint {
                    path: path.clone(),
                    fingerprint: "".to_string(),
                    duration_secs: 0.0,
                }
            }
        })
        .collect()
}

fn process_single_file(path: &str) -> Result<AudioFingerprint> {
    let src = File::open(path).context("failed to open file")?;
    let mss = MediaSourceStream::new(Box::new(src), Default::default());

    let mut hint = Hint::new();
    if let Some(ext) = Path::new(path).extension().and_then(|e| e.to_str()) {
        hint.with_extension(ext);
    }

    let probed = symphonia::default::get_probe()
        .format(&hint, mss, &Default::default(), &Default::default())
        .context("unsupported format")?;

    let mut format = probed.format;
    let track = format
        .tracks()
        .iter()
        .find(|t| t.codec_params.codec != CODEC_TYPE_NULL)
        .ok_or_else(|| anyhow!("no audio track found"))?;

    let mut decoder = symphonia::default::get_codecs()
        .make(&track.codec_params, &Default::default())
        .context("unsupported codec")?;

    let track_id = track.id;
    let sample_rate = track.codec_params.sample_rate.unwrap_or(44100);
    let channels = track.codec_params.channels.unwrap_or_default().count() as u8;

    let mut printer = Fingerprinter::new(&Configuration::preset_test1());
    printer.start(sample_rate as i32, channels as i32)?;

    loop {
        let packet = match format.next_packet() {
            Ok(packet) => packet,
            Err(Error::IoError(_)) => break,
            Err(Error::ResetRequired) => break,
            Err(_) => break,
        };

        if packet.track_id() != track_id {
            continue;
        }

        match decoder.decode(&packet) {
            Ok(audio_buf) => {
                let mut sample_buf =
                    SampleBuffer::<i16>::new(audio_buf.capacity() as u64, *audio_buf.spec());
                sample_buf.copy_interleaved_ref(audio_buf);
                printer.consume(sample_buf.samples());
            }
            Err(Error::DecodeError(_)) => (),
            Err(_) => break,
        }
    }

    printer.finish();

    Ok(AudioFingerprint {
        path: path.to_string(),
        fingerprint: printer.fingerprint().to_string(),
        duration_secs: 0.0,
    })
}
