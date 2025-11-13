#!/bin/bash

# --- COLORS & HELPER FUNCTION ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to ask Yes/No
confirm() {
    while true; do
        read -p "$(echo -e ${YELLOW}"$1 (y/n): "${NC})" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

echo -e "${BLUE}=== Interactive System Setup ===${NC}"
echo "This script will pause at each step to ask for confirmation."
echo ""

# ==============================================================================
# --- SECTION 1: SYSTEM UPDATE ---
# ==============================================================================

if confirm "Do you want to update system repositories and upgrade packages?"; then
    echo -e "${GREEN}[+] Updating system...${NC}"
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl wget git build-essential
else
    echo "Skipping system update."
fi

# ==============================================================================
# --- SECTION 2: APPLICATIONS ---
# ==============================================================================

# Alacritty
if confirm "Install kitty (Terminal)?"; then
    sudo apt install -y kitty
fi

# Firefox
if confirm "Install Firefox?"; then
    sudo apt install -y firefox
fi

# VS Code
if confirm "Install Visual Studio Code?"; then
    echo -e "${GREEN}[+] Installing VS Code...${NC}"
    if ! command -v code &> /dev/null; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt update
        sudo apt install -y code
    else
        echo "VS Code is already installed."
    fi
fi

# Spotify
if confirm "Install Spotify?"; then
    echo -e "${GREEN}[+] Installing Spotify...${NC}"
    if ! command -v spotify &> /dev/null; then
        curl -sS https://download.spotify.com/debian/pubkey_6224F9NNa.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt update
        sudo apt install -y spotify-client
    else
        echo "Spotify is already installed."
    fi
fi

# Discord
if confirm "Install Discord?"; then
    echo -e "${GREEN}[+] Installing Discord...${NC}"
    wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo dpkg -i /tmp/discord.deb
    sudo apt install -f -y # Fix dependencies
    rm /tmp/discord.deb
fi

# Nemo
if confirm "Install Nemo (File Manager)?"; then
    sudo apt install -y nemo
fi

# ==============================================================================
# --- SECTION 3: SHORTCUT HELPER FUNCTIONS ---
# ==============================================================================

# --- SET SHORTCUT FUNCTION ---
# This function injects a shortcut directly into the OS settings
set_shortcut() {
    local name="$1"
    local command="$2"
    local binding="$3"
    local index="$4"

    # Determine Schema based on Desktop Environment
    if gsettings list-schemas | grep -q "org.cinnamon.desktop.keybindings"; then
        # LINUX MINT (CINNAMON)
        SCHEMA="org.cinnamon.desktop.keybindings.custom-keybinding"
        PATH_PREFIX="/org/cinnamon/desktop/keybindings/custom-keybindings/custom${index}/"
        LIST_SCHEMA="org.cinnamon.desktop.keybindings"
        LIST_KEY="custom-list"
    else
        # UBUNTU (GNOME)
        SCHEMA="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
        PATH_PREFIX="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${index}/"
        LIST_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
        LIST_KEY="custom-keybindings"
    fi

    # 1. Define the custom shortcut properties
    gsettings set "$SCHEMA:$PATH_PREFIX" name "$name"
    gsettings set "$SCHEMA:$PATH_PREFIX" command "$command"
    gsettings set "$SCHEMA:$PATH_PREFIX" binding "['$binding']"

    echo "    -> Set '$name' to '$binding'"
}

# --- FINAL LIST BUILDER ---
update_shortcut_list() {
    local count="$1"
    local list_string="["

    # Build the array string like ['custom0', 'custom1', 'custom2']
    for ((i=0; i<count; i++)); do
        if [ "$i" -gt 0 ]; then list_string+=", "; fi

        if gsettings list-schemas | grep -q "org.cinnamon.desktop.keybindings"; then
             list_string+="'custom${i}'"
        else
             list_string+="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/'"
        fi
    done
    list_string+="]"

    # Apply the list to the OS
    if gsettings list-schemas | grep -q "org.cinnamon.desktop.keybindings"; then
        gsettings set org.cinnamon.desktop.keybindings custom-list "$list_string"
    else
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$list_string"
    fi
}

# ==============================================================================
# --- SECTION 4: NATIVE SHORTCUT CONFIGURATION ---
# ==============================================================================

echo -e "${BLUE}=== Native Shortcut Setup ===${NC}"

# Install Dependencies (Still need wmctrl for window actions)
sudo apt install -y wmctrl xdotool gnome-screenshot kitty btop

if confirm "Overwrite all custom shortcuts with your config?"; then

    echo -e "${GREEN}[+] Configuring Shortcuts...${NC}"

    # --- DEFINING SHORTCUTS ---
    # Format: set_shortcut "Name" "Command" "KeyBinding" "IndexNumber"

    # 0. Terminal
    set_shortcut "Terminal" "kitty --start-as fullscreen" "<Super>Return" 0

    # 1. Discord
    set_shortcut "Discord" "discord" "<Super>slash" 1

    # 2. VS Code
    set_shortcut "VS Code" "code" "<Super>v" 2

    # 3. Gemini
    set_shortcut "Gemini Web" "xdg-open https://gemini.google.com" "<Super>g" 3

    # 4. Firefox
    set_shortcut "Firefox" "firefox" "<Super>w" 4

    # 5. Spotify
    set_shortcut "Spotify" "spotify" "<Super>s" 5

    # 6. BTOP (Task manager)
    set_shortcut "btop" "kitty --start-as fullscreen -e btop" "<Ctrl><Shift>Escape" 6

    # 7. Screenshot
    set_shortcut "Screenshot" "gnome-screenshot -a" "<Super><Shift>s" 7

    # 8. Desktop Icons Toggle
    ICON_CMD="bash -c 'v=\$(gsettings get org.nemo.desktop show-desktop-icons); if [ \"\$v\" = \"true\" ]; then gsettings set org.nemo.desktop show-desktop-icons false; else gsettings set org.nemo.desktop show-desktop-icons true; fi'"
    set_shortcut "Toggle Icons" "$ICON_CMD" "<Ctrl><Alt>i" 8

    # 9. Fullscreen Toggle
    set_shortcut "Toggle Fullscreen" "wmctrl -r :ACTIVE: -b toggle,fullscreen" "<Super>f" 9

    # 10. Maximize/Restore
    set_shortcut "Maximize Toggle" "wmctrl -r :ACTIVE: -b toggle,maximized_vert,maximized_horz" "<Super><Shift>m" 10

    # 11. Minimize
    set_shortcut "Minimize" "xdotool getactivewindow windowminimize" "<Super>m" 11

    # --- APPLY LIST ---
    echo -e "${GREEN}[+] Registering shortcuts with OS...${NC}"
    update_shortcut_list 12

    echo -e "${BLUE}Done! Check System Settings > Keyboard > Shortcuts to see them.${NC}"
fi
