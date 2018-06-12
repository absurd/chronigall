#!/usr/bin/env zsh

if [[ -z $COLUMNS ]]; then
    COLUMNS=${size#* }
fi
padlen=$(($COLUMNS - ${#1})) # only works in zsh??
padlen=$(($padlen / 2))
printf "%*s" $padlen
