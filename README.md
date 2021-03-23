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

## mkvtt.sh

WEBVTT generator using `stt.sh` and `detect-sound.sh` below.

### Usage

```sh
./mkvtt.sh -l en input.mp3
```

Sample output:

```vtt
WEBVTT

00:00:00.000 --> 00:00:03.000
beneath it were the words

00:00:03.000 --> 00:00:03.076
stay

00:00:04.040 --> 00:00:04.937
hungry stay foolish

00:00:05.689 --> 00:00:08.174
it was their farewell message as they signed off

00:00:08.867 --> 00:00:09.716
stay hungry

00:00:10.339 --> 00:00:11.199
stay foolish
```

Source: [Steve Jobs's Speech](https://www.youtube.com/watch?v=UF8uR6Z6KLc), 14:07.450 &mdash; 14:19.050

## stt.sh

Speech to Text with Google Cloud Speech-To-Text API.

### Setup

Run `./stt.sh` to find required tools.

Setup `gcloud` and Google Cloud STT by following instructions on [Quickstart](https://cloud.google.com/speech-to-text/docs/quickstart-gcloud).

### Usage

```sh
./stt.sh -l en-US -a audio.mp3
```

Sample Output:

```
0.500   1.100   beneath
1.100   1.100   it
1.100   1.600   were
1.600   1.700   the
1.700   2.200   words
2.200   3       stay
3       3.300   hungry
3.300   4.300   stay
4.300   4.800   foolish
4.800   5.800   it
5.800   5.900   was
5.900   6.100   their
6.100   6.600   farewell
6.600   7       message
7       7.300   as
7.300   7.400   they
7.400   7.800   signed
7.800   8       off
8       9.200   stay
9.200   9.500   hungry
9.500   10.600  stay
10.600  10.900  foolish
```

### Trouble Shooting

401 Unauthorized

* Try `export GOOGLE_APPLICATION_CREDENTIALS=</absolute_path_to_credentials_json>`

## detect-sound.sh

Detect sound ranges.

This tool is useful to set timestamps in subtitles.

Note that it's using silence detection, so any sound will be detected as
positive, even if it's music. It's not using any VAD algorithm.

### Setup

Run `./detect-sound.sh` to find required tools.

### Usage

```sh
./detect-sound.sh audio.mp3

# Use -n to specify sound threshold (default: 0.01)
./detect-sound.sh -n 0.001 audio.mp3

# Use -d to specify duration threshold, in seconds (default: 200ms)
./detect-sound.sh -d 200ms audio.mp3
```

Sample output:

```tsv
0.000 4.75213
4.99764 8.62029
8.87932 15.689
15.9022 17.948
18.3444 20.4788
20.7998 23.6461
23.9415 25.4722
25.8571 26.5015
26.8535 27.5853
27.9495 28.5456
28.8981 29.1532
29.369 31.0953
31.3317 31.3332
31.873 37.152993
```

## License

MIT License, See [LICENSE](./LICENSE) file.
