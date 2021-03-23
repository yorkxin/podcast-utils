#!/usr/bin/env bash

set -e -o pipefail

for tool in go ; do
  if ! command -v $tool > /dev/null 2>/dev/null ; then
    echo "Please install tools:" 1>&2
    echo "brew install go" 1>&2
    exit 1
  fi
done

function print_usage {
  echo "Usage: $(basename "$0") [-d 200ms] [-n 0.01] [-s 3] -l zh-TW input.mp3" 1>&2
  echo "-d    Duration of silence detection" 1>&2
  echo "-n    Noise threshold of silence detection. See https://ffmpeg.org/ffmpeg-filters.html#toc-silencedetect" 1>&2
  echo "-s    Max cue duration in seconds. Subtitles cue will be no longer than this length." 1>&2
  echo
}

duration=200ms
noise=0.01
stretch=3
lang=zh-TW

while getopts 'd:n:l:s:' opt; do
  case $opt in
    d) duration=$OPTARG ;;
    n) noise=$OPTARG ;;
    l) lang=$OPTARG ;;
    s) stretch=$OPTARG ;;
    *)
      print_usage
      exit 1
    ;;
  esac
done

shift $((OPTIND -1))

input="$1"

if [ -z "$input" ] || [ -z "$lang" ] ; then
  print_usage
  exit 1
fi

basename=$(basename "$input")
filename="${basename%.*}"
tmpdir="./tmp/$filename.$(md5 -q "$input" | head -c 7)"
mkdir -p "$tmpdir"

vad_outfile="$tmpdir/vad.txt"
stt_outfile="$tmpdir/stt.txt"

if [ ! -f "$vad_outfile" ] ; then
  ./detect-sound.sh -n "$noise" -d "$duration" "$input" > "$vad_outfile"
fi

if [ ! -f "$stt_outfile" ] ; then
  ./stt.sh -l "$lang" "$input" > "$stt_outfile"
fi

# TODO: this code detects whether mkvtt/main.go should separate words by space
# (for Latin-ish languages). But Google API actually gives us such information.
# Improve this by automatically detecting API response, not whitelisting.
sep=" "
langCode="${lang%-*}"
for unspacedLang in zh ja kr; do
  if [ "$langCode" == $unspacedLang ]; then
    sep=""
  fi
done

go run mkvtt/main.go -stretch "$stretch" -sep "$sep" "$vad_outfile" "$stt_outfile"
