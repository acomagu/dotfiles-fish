function play_gcf_music
    curl 'https://slack.com/api/channels.history?token='$SLACK_API_TOKEN'&channel=C62S25EG5' \
        | jq -r '.messages[].attachments[0] | values | [.original_url,.title] | @tsv' \
        | grep -E 'youtu|nico' | shuf | while read -l line

        echo $line | read -a args
        and set url $args[1]
        and set title "$args[2..-1]"
        and echo "URL: "$url
        and echo "Title: "$title
        and youtube-dl -f 'bestaudio[asr<=44200][abr<=128]/worstaudio/worst[asr>=40000][abr>=120][filesize<=10M]/worst[filesize<=10M]' -o - $url > /tmp/gcf-music
        and cvlc --play-and-exit --no-video --meta-title=$title /tmp/gcf-music
        or echo $status
    end
end
