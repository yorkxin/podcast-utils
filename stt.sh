#!/bin/bash

set -e

for tool in ffmpeg gcloud jq; do
  if ! command -v $tool > /dev/null 2>/dev/null ; then
    echo "Please install tools:" 1>&2
    echo "brew install ffmpeg google-cloud-sdk" 1>&2
    exit 1
  fi
done

function print_usage {
  echo "Usage: $(basename "$0") -l zh-TW audio.mp3 > stt.txt" 1>&2
  echo "NOTE: Google Cloud will charge you API usage fee." 1>&2
}

while getopts 'l:' opt; do
  case $opt in
    l) STT_LANGUAGE=$OPTARG ;;
    *)
      print_usage
      exit 1
    ;;
  esac
done

shift $((OPTIND -1))

AUDIO="$1"

if [ -z "$AUDIO" ] || [ -z "$STT_LANGUAGE" ] ; then
  print_usage
  exit 1
fi

# Google Cloud STT only accepts mono audio. WAV works better.
wav=$(mktemp "$TMPDIR/$(uuidgen)".wav)
ffmpeg -y -loglevel error -i "$AUDIO" -ac 1 -ab 16k "$wav"

gcloud ml speech recognize "$wav" \
    --language-code="$STT_LANGUAGE" \
    --include-word-time-offsets |
    jq -r '.results[0].alternatives[0].words[] | [.startTime, .endTime, .word] | @tsv' |
    sed 's/s\t/\t/g'

unlink "$wav"
