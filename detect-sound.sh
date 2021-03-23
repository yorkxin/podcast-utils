#!/bin/bash

set -e

for tool in ffmpeg sox; do
  if ! command -v $tool > /dev/null 2>/dev/null ; then
    echo "Please install tools:" 1>&2
    echo "brew install ffmpeg sox" 1>&2
    exit 1
  fi
done

function print_usage {
  echo "Usage: $(basename "$0") [-d 0.1] [-n -60dB] audio.mp3" 1>&2
}

function time_to_seconds {
  duration_s=$(gdate -d "$1" +%s)
  duration_ns=$(gdate -d "$1" +%N)
  zero_s=$(gdate -d "00:00:00.000" +%s)
  zero_ns=$(gdate -d "00:00:00.000" +%N)

  echo "scale=6; $duration_s - $zero_s + ($duration_ns - $zero_ns) / 1000000000" | bc
}

DURATION=200ms
NOISE=0.01

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

length=$(soxi -D "$AUDIO")

tmp=$(mktemp)
echo "0.000" > "$tmp"

# silence flags
ffmpeg -i "$AUDIO" -af "silencedetect=d=$DURATION:n=$NOISE" -f null - 2>&1 |
grep -oE "silence_(start|end): \d+\.\d+" |
awk '{ print $2 }' >> "$tmp"

echo "$length" >> "$tmp"

sed '$!N;s/\n/ /' "$tmp"

unlink "$tmp"
