#!/bin/bash
# save_profile.sh - Backs up your CURRENT system config into this repo

# Get the directory where this script is located
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Saving configuration to $REPO_DIR..."

# --- 1. SAVE COMMON CONFIGS (Kitty, Bash, Starship) ---
echo "[+] Backing up Common Configs..."
cp -r ~/.config/kitty/* "$REPO_DIR/configs/common/kitty/" 2>/dev/null
cp ~/.config/starship.toml "$REPO_DIR/configs/common/starship.toml"
cp ~/.bashrc "$REPO_DIR/configs/common/.bashrc"

# --- 2. DETECT OS AND SAVE SPECIFIC CONFIGS ---
if [ -f /etc/arch-release ]; then
    echo "[+] Arch Linux Detected - Saving Hyprland specific files..."

    # Create folders if they don't exist
    mkdir -p "$REPO_DIR/configs/arch/hypr"
    mkdir -p "$REPO_DIR/configs/arch/waybar"
    mkdir -p "$REPO_DIR/configs/arch/rofi"

    # Copy files
    cp -r ~/.config/hypr/* "$REPO_DIR/configs/arch/hypr/"
    cp -r ~/.config/waybar/* "$REPO_DIR/configs/arch/waybar/"
    cp -r ~/.config/rofi/* "$REPO_DIR/configs/arch/rofi/" # Uncomment if you use rofi

    echo "Arch config saved."

elif grep -q "Linux Mint" /etc/os-release; then
    echo "[+] Linux Mint Detected - Saving Cinnamon specific files..."
    # If you have specific Mint files (like opacity scripts), copy them here
    # cp ~/some/script.sh "$REPO_DIR/configs/mint/"
    echo "Mint config saved."
fi

echo "Backup complete! You can now git push."
