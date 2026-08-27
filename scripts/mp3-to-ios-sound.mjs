#!/usr/bin/env node
/**
 * Convert the GlassWave notification MP3 into the format iOS accepts for
 * notification sounds.
 *
 * iOS (UNNotificationSound) only plays Linear PCM, MA4, µ-law or a-law audio
 * wrapped in `.wav`, `.aiff` or `.caf`, and the clip must be shorter than 30 s.
 * MP3 is silently ignored and the system default is played instead, so the
 * native iOS asset is a 16-bit Linear PCM WAV decoded from the same MP3 the
 * web build and the Android build use.
 *
 * The WAV is MONO: a notification chime plays on a single phone speaker, so
 * stereo buys nothing and doubles the file size.
 *
 * Usage:
 *   node scripts/mp3-to-ios-sound.mjs [input.mp3] [output.wav]
 *
 * Defaults:
 *   input   public/sounds/glasswave-notification.mp3
 *   output  ios-capacitor/App/App/glasswave_notification.wav
 */

import fs from "node:fs";
import path from "node:path";
import { MPEGDecoder } from "mpg123-decoder";

/** Cut the decaying tail once it is inaudible (keeps the asset small). */
const SILENCE_THRESHOLD = 0.002; // ~ -54 dBFS
const MIN_DURATION = 1.0; // seconds, never trim shorter than this
const FADE_OUT = 0.15; // seconds of fade so the cut is not a click

const input = process.argv[2] ?? "public/sounds/glasswave-notification.mp3";
const output = process.argv[3] ?? "ios-capacitor/App/App/glasswave_notification.wav";

const decoder = new MPEGDecoder();
await decoder.ready;

const { channelData, samplesDecoded, sampleRate, errors } = decoder.decode(
  new Uint8Array(fs.readFileSync(input))
);
decoder.free();

if (errors?.length) {
  console.warn(`[mp3-to-ios-sound] decoder reported ${errors.length} recoverable error(s)`);
}
if (!samplesDecoded) {
  throw new Error(`No audio decoded from ${input}`);
}

const sourceChannels = channelData.length;
// Downmix to mono (see header comment): halves the payload with no audible
// difference on a notification speaker.
const channels = 1;
const mixed =
  sourceChannels === 1
    ? channelData[0]
    : (() => {
        const out = new Float32Array(samplesDecoded);
        for (let i = 0; i < samplesDecoded; i++) {
          let s = 0;
          for (let c = 0; c < sourceChannels; c++) s += channelData[c][i];
          out[i] = s / sourceChannels;
        }
        return out;
      })();

// Ignore the encoder/decoder padding at the very end of the stream: it is not
// part of the sound but can hold a few non-zero samples that defeat trimming.
const PADDING = Math.round(sampleRate * 0.1);

// Find the last sample that is still audible.
let end = Math.max(samplesDecoded - PADDING, Math.ceil(sampleRate * MIN_DURATION));
while (end > sampleRate * MIN_DURATION) {
  const i = end - 1;
  if (Math.abs(mixed[i]) > SILENCE_THRESHOLD) break;
  end--;
}

// Fade the last few milliseconds out so trimming cannot introduce a click.
const fadeSamples = Math.min(Math.round(sampleRate * FADE_OUT), end);
const pcm = Buffer.alloc(end * channels * 2);
for (let i = 0, offset = 0; i < end; i++) {
  const fade = i >= end - fadeSamples ? (end - i) / fadeSamples : 1;
  const sample = Math.max(-1, Math.min(1, mixed[i] * fade));
  pcm.writeInt16LE(Math.round(sample * 32767), offset);
  offset += 2;
}

const header = Buffer.alloc(44);
header.write("RIFF", 0);
header.writeUInt32LE(36 + pcm.length, 4);
header.write("WAVE", 8);
header.write("fmt ", 12);
header.writeUInt32LE(16, 16); // PCM fmt chunk size
header.writeUInt16LE(1, 20); // format 1 = Linear PCM
header.writeUInt16LE(channels, 22);
header.writeUInt32LE(sampleRate, 24);
header.writeUInt32LE(sampleRate * channels * 2, 28); // byte rate
header.writeUInt16LE(channels * 2, 32); // block align
header.writeUInt16LE(16, 34); // bits per sample
header.write("data", 36);
header.writeUInt32LE(pcm.length, 40);

fs.mkdirSync(path.dirname(output), { recursive: true });
fs.writeFileSync(output, Buffer.concat([header, pcm]));

console.log(
  `wrote ${output} — ${(end / sampleRate).toFixed(2)}s, ${sampleRate} Hz, ` +
    `${channels === 1 ? "mono" : "stereo"}, 16-bit PCM ` +
    `(${(fs.statSync(output).size / 1024).toFixed(0)} KB)`
);
