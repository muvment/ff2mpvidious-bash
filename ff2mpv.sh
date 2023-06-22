#!/bin/bash
# json parsing is for schmucks (Written by Ckath)
# Modified from https://github.com/Ckath/ff2mpv-bash to proxy videos through invidious

while read -rN 1 C && [ "$C" != "}" ]; do D="$D$C"; done
raw_url="$D"
if [ -n "$raw_url" ];then

    array[0]="https://yt.artemislena.eu"
    array[1]="https://yt.artemislena.eu"
    array[2]="https://invidious.baczek.me"

    size=${#array[@]}
    index=$(($RANDOM % $size))
    inv_url=$(echo ${array[$index]})

    url="$(echo "$raw_url" | sed 's/.*:"//;s/"//')"

    check () {
    format=$(yt-dlp -F "$url" | grep "720")
    if [[ "$format" =~ "720" ]]; then
    tag="22"
    else
    tag="18"
    fi
    }

    dir="/tmp/1.jpg"

    api_url=$(echo "$url" | sed "s+.*watch?v=+$inv_url/api/v1/videos/+;s+.*latest_version?id=+$inv_url/api/v1/videos/+;s/\&itag=.*//g;s/\&local=true//g;s/.*/&?fields=title,author,videoThumbnails/")

    cmd=$(curl -sS "$api_url")

    author=$(echo "$cmd" | jq '.author, .title' | awk 'FNR == 1 {print $0}' | sed 's/"//g')

    title=$(echo "$cmd" | jq '.author, .title' | awk 'FNR == 2 {print $0}' | sed 's/"//g')

    img_url=$(echo "$cmd" | jq '.videoThumbnails[] | .url' | grep -Po '.*?1.jpg' | sed 's/"//g')


    if [[ "$url" =~ "youtube.com" || "$url" =~ "youtu.be" ]] && [[ "$url" =~ "watch?v=" ]];then
    curl -sS "$img_url" --output "$dir"
    check
    mpv_url=$(echo "$url" \
    | sed "s,.*watch?v=,$inv_url/latest_version?id=,g;s/$/\&itag=${tag}\&local=true/g")

    elif [[ "$url" =~ "youtube.com" || "$url" =~ "youtu.be" ]] && [[ ! "$url" =~ "watch?v=" ]];then
    curl -sS "$img_url" --output "$dir"
    check
    mpv_url=$(echo "$url" \
    | sed "s,.*com/,$inv_url/latest_version?id=,g;s,.*be/,$inv_url/latest_version?id=,g;s/$/\&itag=${tag}\&local=true/g")

    elif [[ ! "$url" =~ "piped" || ! "$url" =~ "youtube.com" || ! "$url" =~ "youtu.be" ]] && [[ "$url" =~ "watch?v=" ]];then
    curl -sS "$img_url" --output "$dir"
    check
    mpv_url=$(echo "$url" | sed "s,.*watch?v=,$inv_url/latest_version?id=,;s/$/\&itag=${tag}\&local=true/g")

    elif [[ "$url" =~ "&itag=18" || "$url" =~ "&itag=22" ]] && [[ ! "$url" =~ "&local=true" ]];then
    mpv_url=$(echo "$url" | sed "s,.*watch?v=,$inv_url/latest_version?id=,;s/$/\&local=true/g")
    curl -sS "$img_url" --output "$dir"

    elif [[ "$url" =~ "latest_version" ]] && [[ ! "$url" =~ "&local=true" ]];then
    mpv_url=$(echo "$url" | sed 's/$/\&local=true/')
    curl -sS "$img_url" --output "$dir"

    elif [[ "$url" =~ "latest_version" ]] && [[ "$url" =~ "&local=true" ]];then
    mpv_url="$url"
    curl -sS "$img_url" --output "$dir"

    elif [[ "$url" =~ "lbry" ]];then
    mpv_url=$(echo "$url" | sed 's/.*https/https/')

    elif [[ "$url" =~ "tok" ]];then
    mpv_url=$(echo "$url" | sed 's/.*https/https/')

    elif [ -z "$url" ];then
    notify-send "Invalid URL"
    exit 0

    else
    mpv_url="$url"

    fi

fi

if [[ -n "$author" || -n "$title" || "$url" =~ "youtube.com" || "$url" =~ "youtu.be" || "$url" =~ "watch?v=" || "$url" =~ "latest_version" ]]; then
notify-send -i "$dir" "$author" "$title"

elif [[ -z "$author" || -z "$title" || -z "$dir" || "$url" =~ "youtube.com" || "$url" =~ "youtu.be" || "$url" =~ "watch?v=" || "$url" =~ "latest_version" ]]; then
notify-send -t 0 "Error:" "Couldn't retrieve information\nBase url:\n$raw_url\nParsed url:\n$mpv_url"

else
notify-send "Opening video:" "$mpv_url"

fi

mpv --no-terminal "$mpv_url"
rm "$dir"
exit 1
