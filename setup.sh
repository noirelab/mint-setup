#!/bin/bash

# --- COLORS & HELPER FUNCTION ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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
echo "Script is running from: $SCRIPT_DIR"
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

if confirm "Install common packages?"; then
    sudo apt install git nala
fi
# Kitty
if confirm "Install kitty (Terminal)?"; then
    sudo apt install -y kitty

    if [ -d "$SCRIPT_DIR/kitty" ]; then
        echo -e "${GREEN}[+] Installing Kitty config...${NC}"
        mkdir -p ~/.config/kitty
        cp "$SCRIPT_DIR/kitty/Ayu.conf" ~/.config/kitty/
        cp "$SCRIPT_DIR/kitty/current-theme.conf" ~/.config/kitty/
        cp "$SCRIPT_DIR/kitty/kitty.conf" ~/.config/kitty/
        echo "Kitty config files copied to ~/.config/kitty/"
    else
        echo -e "${YELLOW}Warning: 'kitty' directory not found in $SCRIPT_DIR/scripts. Skipping Kitty config.${NC}"
    fi
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
    if ! command -v discord &> /dev/null; then
        wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
        sudo dpkg -i /tmp/discord.deb
        sudo apt install -f -y # Fix dependencies
        rm /tmp/discord.deb
    else
        echo "Discord is already installed."
    fi
fi

# Nemo
if confirm "Install Nemo (File Manager)?"; then
    sudo apt install -y nemo
fi

# ==============================================================================
# --- SECTION 2.5: DEV TOOLS (Docker & Miniconda) ---
# ==============================================================================

# Docker
if confirm "Install Docker (Engine + Compose)?"; then
    echo -e "${GREEN}[+] Installing Docker...${NC}"

    # 1. Add Docker's official GPG key:
    sudo apt update
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # 2. Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update

    # 3. Install packages
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 4. Post-install: Add user to docker group (avoids using sudo for docker)
    echo -e "${GREEN}[+] Adding user '$USER' to the docker group...${NC}"
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}NOTE: You may need to log out and back in for Docker group changes to take effect.${NC}"
fi

# Miniconda
if confirm "Install Miniconda3?"; then
    echo -e "${GREEN}[+] Installing Miniconda3...${NC}"
    mkdir -p ~/miniconda3
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm ~/miniconda3/miniconda.sh

    # Init bash so conda command is available
    echo -e "${GREEN}[+] Initializing conda for bash...${NC}"
    ~/miniconda3/bin/conda init bash
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

# Install Dependencies (wmctrl for window actions)
sudo apt install -y wmctrl xdotool gnome-screenshot btop

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

# ==============================================================================
# --- SECTION 5: DOTFILE & CUSTOM SCRIPTS ---
# ==============================================================================

echo -e "${BLUE}=== Dotfile & Custom Scripts Setup ===${NC}"

# --- Bashrc Configuration ---
if confirm "Install custom .bashrc and starship.toml?"; then
    # --- BASHRC SECTION ---
    if [ -f "$SCRIPT_DIR/scripts/.bashrc" ]; then
        echo -e "${GREEN}[+] Installing .bashrc...${NC}"

        # Backup existing .bashrc
        if [ -f ~/.bashrc ]; then
            BACKUP_FILE=~/.bashrc.bak_$(date +%F-%T)
            echo "Backing up existing ~/.bashrc to $BACKUP_FILE"
            mv ~/.bashrc "$BACKUP_FILE"
        fi

        # FIX: Removed the extra quote at the end
        cp "$SCRIPT_DIR/scripts/.bashrc" ~/.bashrc

        echo -e "${YELLOW}Successfully installed .bashrc.${NC}"
        echo -e "${YELLOW}Please run 'source ~/.bashrc' or restart your terminal to apply changes.${NC}"
    else
        echo -e "${YELLOW}Warning: '.bashrc' file not found in $SCRIPT_DIR/scripts. Skipping install.${NC}"
    fi

    if [ -f "$SCRIPT_DIR/scripts/starship.toml" ]; then
        echo -e "${GREEN}[+] Installing starship.toml...${NC}"
        cp "$SCRIPT_DIR/scripts/starship.toml" ~/.config/starship.toml
        echo -e "${YELLOW}Successfully installed starship.toml.${NC}"
    else
         echo -e "${YELLOW}Warning: starship.toml not found.${NC}"
    fi
fi

# --- Opacify Windows Script ---
if confirm "Install 'Opacify Windows' script (Transparency effects)?"; then
    # Check dependencies again just in case
    if ! dpkg -s xdotool wmctrl >/dev/null 2>&1; then
         echo "Installing missing dependencies (xdotool, wmctrl)..."
         sudo apt install -y xdotool wmctrl
    fi

    if [ -f "$SCRIPT_DIR/scripts/opacify_windows.sh" ]; then
        echo -e "${GREEN}[+] Installing Opacify Windows...${NC}"

        # 1. Prepare directories
        mkdir -p ~/.local/bin
        mkdir -p ~/.config/autostart

        # 2. Copy Script & Make Executable
        cp "$SCRIPT_DIR/scripts/opacify_windows.sh" ~/.local/bin/
        chmod +x ~/.local/bin/opacify_windows.sh

        # 3. Create Autostart Entry (.desktop file)
        echo "[Desktop Entry]
Type=Application
Exec=$HOME/.local/bin/opacify_windows.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Opacify Windows
Comment=Adjust window opacity based on focus" > ~/.config/autostart/opacify_windows.desktop

        echo -e "-> Script copied to ~/.local/bin/"
        echo -e "-> Autostart entry created in ~/.config/autostart/"

        # 4. Run immediately?
        if confirm "Start Opacify Windows now (so you don't have to reboot)?"; then
            nohup ~/.local/bin/opacify_windows.sh >/dev/null 2>&1 &
            echo "Opacify Windows started!"
        fi
    else
        echo -e "${YELLOW}Warning: 'opacify_windows.sh' not found in $SCRIPT_DIR/scripts. Skipping.${NC}"
    fi
fi

# ==============================================================================
# --- SECTION 6: SHELL ENHANCEMENTS ---
# ==============================================================================

echo -e "${BLUE}=== Shell Enhancements ===${NC}"

# --- Atuin ---
if confirm "Install Atuin (better shell history)?"; then
    echo -e "${GREEN}[+] Installing Atuin...${NC}"
    bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
fi


echo ""
echo -e "${BLUE}=== System Setup Complete ===${NC}"
