#!/bin/bash

set -e

if ! command -v ffmpeg gcloud curl > /dev/null 2>/dev/null ; then
  echo "Please install ffmpeg, google-cloud-sdk and curl" 1>&2
  echo "ffmpeg: brew install ffmpeg" 1>&2
  echo "gcloud: brew install google-cloud-sdk" 1>&2
  echo "curl: brew install curl" 1>&2
  exit 1
fi

function print_usage {
  echo "Usage: $(basename $0) -l zh-TW -a audio.mp3 > output.json" 1>&2
  echo "NOTE: Google Cloud will charge you API usage fee." 1>&2
}

while getopts 'a:l:' opt; do
  case $opt in
    a) AUDIO=$OPTARG ;;
    l) STT_LANGUAGE=$OPTARG ;;
    *)
      print_usage
      exit 1
    ;;
  esac
done

if [ -z "$AUDIO" ] || [ -z "$STT_LANGUAGE" ] ; then
  print_usage
  exit 1
fi

# Google Cloud STT only accepts mono audio. WAV works better.
audio_payload=$(ffmpeg -i "$AUDIO" -ac 1 -f wav - | base64)

data=$(cat << EOS
{
  "config": {
    "encoding":"linear16",
    "languageCode":"$STT_LANGUAGE",
    "enableWordTimeOffsets":true,
    "enableAutomaticPunctuation":true
  },
  "audio": {
    "content":"$audio_payload"
  }
}
EOS
)

# XXX: for some reason if you pipe gcloud output to elsewhere the texts will become ???? (mojibake)
# So use curl instead.
echo "$data" |
  curl -X POST \
    -s \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
    --data @- \
    https://speech.googleapis.com/v1/speech:recognize
