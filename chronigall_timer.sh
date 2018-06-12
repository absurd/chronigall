#!/usr/bin/env bash



# constants
init_text="  WORKSPACE  READY  "
status_work_text="  STATUS: WORKING  "
status_repose_text="  STATUS: REPOSE  "

init_padding=$(centerpad "$init_text")
status_work_padding=$(centerpad "$status_work_text    XX:XX:XX")
status_repose_padding=$(centerpad "$status_repose_text    XX:XX:XX")

init_msg=$(printf '%s%s%s%s%s%s' "$(tput setab 12)" "$(tput setaf 0)" "$(tput bold)" "$(tput blink)" "$init_text" "$(tput sgr0)")
status_work_msg=$(printf '%s%s%s%s%s' "$(tput setab 35)" "$(tput setaf 0)" "$(tput bold)"  "$status_work_text" "$(tput sgr0)")
status_repose_msg=$(printf '%s%s%s%s%s' "$(tput setab 3)" "$(tput setaf 0)" "$(tput bold)"  "$status_repose_text" "$(tput sgr0)")
status_repose_msg_long=$(printf '%s%s%s%s%s' "$(tput setab 124)" "$(tput setaf 0)" "$(tput bold)"  "$status_repose_text" "$(tput sgr0)")

repose_scorn_threshold=5
timelog_file=$(findlocalest "meta/timelog.md")


# Initialize status variables

work_duration=0
work_start=0

repose_duration=0

mode_duration=$work_duration
status_mode_padding=$status_work_padding
status_mode_msg=$status_work_msg

timer_loop=true
mode='work'


print_hms() {
    printf '%02d:%02d:%02d\n' $(($mode_duration/3600)) $(($mode_duration%3600/60)) $(($mode_duration%60))
}

parse_input() {
    if [[ $input_key == 'q' ]]; then
        pre_cleanup
        cleanup
    elif [[ $input_key == ' ' ]]; then
        if [[ $mode == 'work' ]]; then
            work_duration=$mode_duration
            work_start=$mode_start
            mode='repose'
            mode_duration=$repose_duration
            status_mode_padding=$status_repose_padding
            status_mode_msg=$status_repose_msg
        else
            repose_duration=$mode_duration
            repose_start=$mode_start
            mode='work'
            mode_duration=$work_duration
            status_mode_padding=$status_work_padding
            status_mode_msg=$status_work_msg
        fi
        mode_start=$(($(date '+%s') - mode_duration))
    fi
    input_key=''
}

write_to_timelog() {
    clear
    echo "DESCRIBE WORKBLOCK:"
    read desc
    if [[ $desc != 'discard' ]]; then
        echo "" >> $timelog_file
        #echo "#"$(aenow) >> $timelog_file
        echo "#"$(gdate --rfc-3339=seconds) >> $timelog_file
        if [[ -z "${desc// }" ]]; then
            echo $(hms $work_duration) >> $timelog_file
        else
            echo $(hms $work_duration)" -- "$desc >> $timelog_file
        fi
        echo "> "$(hms $repose_duration)" -- repose" >> $timelog_file
        echo "> Efficiency: "$(( work_duration * 100 / (work_duration + repose_duration) ))"%" >> $timelog_file
    fi
}

final_output() {
    if [[ $desc != 'discard' ]]; then
        mode_duration=work_duration
        #voice " End workblock. $(print_hms)"
        printf '\nWork: %s\n' $(print_hms)
        mode_duration=repose_duration
        printf 'Repose: %s\n' $(print_hms)
    fi
}

sigint_final_output() {
    mode_duration=work_duration
    #if [[ work_duration -gt 0 ]]; then
        #voice "Aborted work block. $(print_hms)"
    #else
        #voice " Aborted work block."
    #fi
    printf '\nWork: %s\n' $(print_hms)
    mode_duration=repose_duration
    printf 'Repose: %s\n' $(print_hms)
}

pre_cleanup() {
    if [[ $mode == 'work' ]]; then
        work_duration=$mode_duration
    else
        repose_duration=$mode_duration
    fi
    timer_loop=false
}

cleanup() {
    pre_cleanup; tput sgr0; tput cnorm; write_to_timelog; tput rmcup || clear; final_output; exit 0
}

sigint_cleanup() {
    pre_cleanup; tput sgr0; tput cnorm; tput rmcup || clear; sigint_final_output; exit 0
}


if [ -z $timelog_file ]; then
    echo ""
    echo "Can't find project timelog file."
    echo "Are you in the right directory?"
    echo "If so, (create meta dir and) touch meta/timelog.md from project directory root."
    exit;
fi

trap sigint_cleanup SIGINT
tput smcup
tput civis
printf "\n$init_padding$init_msg"
read -n 1 -s -r
work_start=$(($(date '+%s') - work_duration))
mode_start=$work_start
#voice "Begin workblock"
while $timer_loop; do
    clear
    mode_duration=$(($(date '+%s') - mode_start))
    hms=$(print_hms)
    printf "\n$status_mode_padding$status_mode_msg     $hms"
    # Set IFS to empty string so that read doesn't trim
    IFS= read -rsn1 -t 1 input_key # wait for key entry for 1 sec before continuing
    parse_input
    if [[ $mode == 'repose' && $mode_duration -gt $work_duration ]]; then
        status_mode_msg=$status_repose_msg_long
    fi
done

