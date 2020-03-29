#!/bin/bash

set -e

if ! command -v ffmpeg > /dev/null 2>/dev/null ; then
  echo "Please install ffmpeg" 1>&2
  echo "ffmpeg: brew install ffmpeg" 1>&2
  exit 1
fi

function print_usage {
  echo "Usage: $(basename $0) -s subtitle.vtt -i image.png -a audio.mp3 -o output.mp4" 1>&2
}

while getopts 'i:a:o:s:' opt; do
  case $opt in
    s) SUBTITLES=$OPTARG ;;
    a) AUDIO=$OPTARG ;;
    i) IMAGE=$OPTARG ;;
    o) OUTPUT=$OPTARG ;;
    *)
      print_usage
      exit 1
    ;;
  esac
done

shift $((OPTIND -1))

if [ -z "$IMAGE" ] || [ -z "$AUDIO" ] || [ -z "$OUTPUT" ] || [ -z "$SUBTITLES" ]; then
  print_usage
  exit 1
fi

tempfile=$(mktemp script.XXXXXX)

cat <<EOF > "$tempfile"
[1:a]
showwaves=
  s=840x840:
  mode=cline:
  rate=25:
  colors=black
[waveform];

[0:v][waveform]
overlay=
  x=80:
  y=80:
  shortest=1,
subtitles=
  $SUBTITLES:
  force_style='PlayResX=1000,PlayResY=1000,FontName=jf-openhuninn-1.0,Fontsize=70,Outline=0,Alignment=4,MarginL=0080,MarginV=0700,PrimaryColour=&H000000&'
[final]
EOF

ffmpeg -loop 1 -i "$IMAGE" -i "$AUDIO" -filter_complex_script "$tempfile" -map "[final]" -map 1:a "$OUTPUT"

unlink "$tempfile"
