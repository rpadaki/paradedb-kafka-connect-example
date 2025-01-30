#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number_of_messages>"
    exit 1
fi

echo "Producing $1 JSON messages to kafka topic..."
count=0

while [ $count -lt $1 ]; do
    senders=("alice" "bob" "charlie" "david" "eve" "frank" "grace" "henry" "ivy" "jack")
    adjectives=("happy" "sad" "excited" "tired" "energetic" "lazy" "busy" "relaxed" "angry" "calm")
    verbs=("am" "feel" "look" "seem" "appear")
    greetings=("hello" "hi" "hey" "howdy" "good morning" "good evening" "good day")
    questions=("how are you?" "what's up?" "how's it going?" "what's new?" "how was your day?")
    statements=("nice day" "beautiful weather" "crazy times" "busy week" "fun weekend")
    reactions=("wow!" "great!" "awesome!" "cool!" "fantastic!" "amazing!" "interesting!")
    farewells=("bye" "see you" "take care" "catch you later" "until next time" "goodbye")

    sender=${senders[$RANDOM % ${#senders[@]}]}
    target=${senders[$RANDOM % ${#senders[@]}]}

    # Construct more varied messages
    message_type=$((RANDOM % 5))
    case $message_type in
        0) message="${greetings[$RANDOM % ${#greetings[@]}]}";;
        1) message="${questions[$RANDOM % ${#questions[@]}]}";;
        2) message="I ${verbs[$RANDOM % ${#verbs[@]}]} ${adjectives[$RANDOM % ${#adjectives[@]}]}";;
        3) message="${statements[$RANDOM % ${#statements[@]}]} ${reactions[$RANDOM % ${#reactions[@]}]}";;
        4) message="${farewells[$RANDOM % ${#farewells[@]}]}";;
    esac

    json="{\"schema\":{\"type\":\"struct\",\"fields\":[{\"field\":\"sender\",\"type\":\"string\"},{\"field\":\"target\",\"type\":\"string\"},{\"field\":\"contents\",\"type\":\"string\"}]},\"payload\":{\"sender\":\"$sender\",\"target\":\"$target\",\"contents\":\"$message\"}}"

    echo $json

    ((count++))
done | docker compose exec -T kafka-broker kafka-console-producer --topic messages --broker-list localhost:9092
