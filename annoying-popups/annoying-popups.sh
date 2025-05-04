#!/bin/bash
# annoying-popups - Blame Microsoft™

# Require sudo, run in background silently
if [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

# --- Function: Play random sound effect ---
play_random_sound() {
    sound_cmd=""
    volume=$((RANDOM % 100 + 10))

    if command -v canberra-gtk-play &>/dev/null; then
        canberra-gtk-play -i dialog-warning -V "$volume" &
    elif command -v aplay &>/dev/null; then
        find /usr/share/sounds -type f \( -iname '*.wav' -o -iname '*.ogg' \) 2>/dev/null | shuf -n1 | while read -r s; do
            aplay -q "$s" &
        done
    elif command -v beep &>/dev/null; then
        beep -f $((RANDOM % 3000 + 200)) -l $((RANDOM % 300 + 50)) &
    fi
}

# --- Function: Generate dynamic popup content ---
generate_message() {
    headline=$(shuf -n1 -e \
        "Activate Your Linux Today!" \
        "Your Free Trial Has Expired!" \
        "System Overload Detected!" \
        "Suspicious Activity Detected!" \
        "Kernel Panic Inbound!" \
        "Windows 11 Upgrade Ready!" \
        "Unauthorized Access Blocked!")

    uptime=$(uptime -p)
    mem=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    date=$(date)
    who=$(whoami)

    echo "<b>$headline</b>\n\nUser: $who\nUptime: $uptime\nMemory: $mem\nDate: $date"
}

# --- Function: Show annoying popup ---
show_popup() {
    local msg width height x y
    msg=$(generate_message)
    width=$((RANDOM % 1000 + 200))
    height=$((RANDOM % 600 + 100))
    x=$((RANDOM % 1200))
    y=$((RANDOM % 700))

    yad --title="System Notification" \
        --text="$msg" \
        --button="Click:0" --button="OK:1" --button="Remind me:2" \
        --width="$width" --height="$height" --on-top \
        --pos="$x,$y" --no-wrap >/dev/null 2>&1

    play_random_sound

    # 25% chance to immediately spawn another popup
    if (( RANDOM % 100 < 25 )); then
        show_popup
    fi

    # If "Remind me" clicked (exit code 2), show chain confirmations
    if [[ $? -eq 2 ]]; then
        loop=$((RANDOM % 3 + 1))
        for ((i=0; i<loop; i++)); do
            yad --title="Confirmation Required" \
                --text="<b>Are you sure tho?</b>" \
                --button="Yes:0" --button="No:1" \
                --width=$((RANDOM % 400 + 100)) \
                --height=$((RANDOM % 300 + 80)) \
                --on-top --pos="$((RANDOM % 1000)),$((RANDOM % 700))" >/dev/null 2>&1
            play_random_sound
        done
    fi
}

# --- Run loop in background ---
(
while true; do
    sleep $((RANDOM % 100 + 20))
    show_popup
done
) &
