#!/bin/bash

# Get active window info
window_info=$(hyprctl activewindow -j)
window_class=$(echo "$window_info" | jq -r '.class')

# --- FIX: Handle empty/null window state ---
if [[ "$window_class" == "null" ]] || [[ -z "$window_class" ]]; then
    # Return empty text and a specific class so we can hide it in CSS
    echo "{\"text\":\"\", \"class\":\"empty\", \"tooltip\":\"Desktop\"}"
    exit 0
fi

window_title=$(echo "$window_info" | jq -r '.title')

# Determine icon and format based on class
case "$window_class" in
    firefox*|Navigator)
        icon="firefox"
        text=$(echo "$window_title" | sed 's/ — Mozilla Firefox$//')
        ;;
    code|Code)
        icon="code"
        text=$(echo "$window_title" | sed 's/ - Visual Studio Code$//')
        ;;
    discord|Discord)
        icon="discord"
        text=$(echo "$window_title" | sed 's/ - Discord$//')
        ;;
    [Ss]potify)
        icon="spotify"
        text=$(echo "$window_title" | sed 's/ - Spotify$//')
        ;;
    kitty|Alacritty)
        icon="kitty"
        text="$window_title"
        ;;
    *)
        icon="default"
        text="$window_title"
        ;;
esac

# Limit text length
if [ ${#text} -gt 50 ]; then
    text="${text:0:47}..."
fi

# Output JSON for Waybar
echo "{\"text\":\"$text\",\"class\":\"$icon\",\"tooltip\":\"$window_title\"}"
