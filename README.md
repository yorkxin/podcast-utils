# amcyfm-utils

Utilities for [amcy.fm](https://amcy.fm/) Podcast Production

## audiogram.sh

Composite video with background image, audio, waveform animation, and subtitles.

### Hard-coded configuration

* Background image is 1000x1000 pixels
* waveform style is `cline`, black, 25 fps, 840x840, center-positioned
* Subtitles is rendered with
    * font family `jf-openhuninn-1.0` (installed on your computer)
    * font size 70px
    * color `black`
    * no outline
    * margin top 700 px from the canvas

### Setup

macOS

```sh
brew install ffmpeg
```

### Usage

```sh
./audiogram.sh -s subtitles.vtt -i image.png -a audio.mp3 -o video.mp4
```

Any format that is accepted by FFmpeg is accepted, for example:

- `-s` subtitles: `vtt`, `ass`, `srt`
- `-i` image: `png`, `jpg`
- `-a` audio: `mp3`, `wav`
- `-o` output video: `mp4`, `avi`

## stt.sh (deprecated)

NOTE: deprecated. See [Autosub Usage](#autosub-usage) for my current workflow.

Speech to Text with Google Cloud Speech-To-Text API.

This is to simplify subtitles workflow.

### Setup

macOS

```sh
brew install ffmpeg google-cloud-sdk curl
```

Setup `gcloud` and Google Cloud STT by following instructions on [Quickstart](https://cloud.google.com/speech-to-text/docs/quickstart-gcloud).

### Usage

```sh
./stt.sh -l zh-TW -a audio.mp3 > output.json
```

### Trouble Shooting

401 Unauthorized

* Try `export GOOGLE_APPLICATION_CREDENTIALS=</absolute_path_to_credentials_json>`

## detect-silence.sh

Detect silence ranges.

This tool is useful to set timestamps in subtitles.

### Setup

macOS

```sh
brew install ffmpeg jq
```

### Usage

```sh
./detect-silence.sh audio.mp3

# Use -n to specify silence threshold (default: -60dB)
./detect-silence.sh -n -30dB audio.mp3

# Use -d to specify duration threshold, in seconds (default: 0.1)
./detect-silence.sh -d 0.3 audio.mp3
```

Output is a JSON like this:

```json
[
  {
    "start": 0,
    "end": 0.37737
  },
  {
    "start": 3.55317,
    "end": 4.0927
  },
  {
    "start": 6.52252,
    "end": 6.65796
  },
  {
    "start": 8.39494,
    "end": 8.57649
  },
  {
    "start": 10.0297,
    "end": 10.4743
  }
]
```

## Autosub Usage

Speech-to-Text (STT) using Google Cloud API. This tool generates VTT files so you can apply to ffmpeg.

You'll need to signup for Google Cloud API and enable Speech-to-Text API. See [Google STT Quickstart](https://cloud.google.com/speech-to-text/docs/quickstart-gcloud) for details.

Not to be confused with the original unmaintained `autosub`.

### Install

```bash
pip3 install git+https://github.com/BingLingGroup/autosub.git@alpha ffmpeg-normalize
```

### Usage

```bash
export LC_CTYPE=en_US.UTF-8 # Workaround Python locale normalizer bug <-- IMPORTANT
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/gcloud/api/credential.json
autosub -sapi gcsv1 -i audio.mp3 -S cmn-hant-tw -F vtt
```

Now you can edit the `vtt` file. See also: [Web Video Text Tracks Format (WebVTT) - Web APIs | MDN](https://developer.mozilla.org/en-US/docs/Web/API/WebVTT_API)

## License

MIT License, See [LICENSE](./LICENSE) file.
