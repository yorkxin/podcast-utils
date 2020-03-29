# amcyfm-utils

Utilities for [amcy.fm](https://amcy.fm/) Podcast Production

## audiogram.sh

Composite video with background image, audio, waveform animation, and subtitles.

### Setup

macOS

```sh
brew install ffmpeg envsubst
# Be sure to add /usr/local/opt/gettext/bin to $PATH
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

## stt.sh

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

## License

MIT License, See [LICENSE](./LICENSE) file.
