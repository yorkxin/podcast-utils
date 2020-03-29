# amcyfm-utils

Utilities for amcy.fm Podcast Production

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


