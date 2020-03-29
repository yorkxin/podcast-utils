#!/bin/bash

set -e

if ! command -v ffmpeg jq > /dev/null 2>/dev/null ; then
  echo "Please install ffmpeg and jq" 1>&2
  echo "ffmpeg: brew install ffmpeg" 1>&2
  echo "jq: brew install jq" 1>&2
  exit 1
fi

function print_usage {
  echo "Usage: $(basename $0) [-d 0.1] [-n -60dB] audio.mp3" 1>&2
}

DURATION=0.1
NOISE=-60dB

while getopts 'd:n:' opt; do
  case $opt in
    d) DURATION=$OPTARG ;;
    n) NOISE=$OPTARG ;;
    *)
      print_usage
      exit 1
    ;;
  esac
done

shift $((OPTIND -1))

AUDIO="$1"

if [ -z "$AUDIO" ]; then
  print_usage
  exit 1
fi

tempfile=$(mktemp ffmpeg.out.XXXXXX)

if ! ffmpeg -i "$AUDIO" -af "silencedetect=d=$DURATION:n=$NOISE" -f null - 2>"$tempfile"; then
  echo "ERROR" 1>&2
  cat "$tempfile" 1>&2
  rm "$tempfile"
  exit 1
fi

cat "$tempfile" |
  grep -E '^\[silencedetect' |
  awk -F '] ' '{ print $2 }' |
  sed -E 's/ \| silence_duration: .+//g' |
  sort -k 2 -t ':' --general-numeric-sort | # to prevent mixed output lines
  sed 'N;s/\n/, /' | # join consequent two lines
  sed -E 's/silence_([a-z]+):/"\1":/g' |
  sed -E 's/^(.+)$/{ \1 }/' |
  jq --slurp --monochrome-output

rm "$tempfile"
