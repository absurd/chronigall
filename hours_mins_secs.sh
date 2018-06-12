#!/usr/bin/env zsh

num=$1
min=0
hour=0
day=0
if (( num>59 )); then
    ((sec=num%60))
    ((num=num/60))
    if ((num>59)); then
        ((min=num%60))
        ((hour=num/60))
    else
        ((min=num))
    fi
else
    ((sec=num))
fi
printf "%02d:%02d:%02d" $hour $min $sec
