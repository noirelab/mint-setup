# Linux Setup

Configuration files and scripts for Linux Mint and Arch Linux environments.

## Supported Systems
- **Linux Mint**: Cinnamon desktop with window opacity effects
- **Arch Linux**: Hyprland compositor with Waybar, Rofi, and SDDM

## Applications
- Kitty: Terminal Emulator
- Discord: Voice and Text Chat
- Visual Studio Code: Code Editor
- Firefox: Web Browser
- Spotify: Music Streaming
- btop: System Monitor
- Docker: Containerization platform
- Miniconda3: Python package manager

## Configuration Files
- `configs/common/`: Kitty, Starship, Bash (shared between distros)
- `configs/arch/`: Hyprland, Waybar, Rofi
- `configs/mint/`: Window opacity script

## Keyboard Shortcuts
### Applications
- Kitty: Super + Enter
- Discord: Super + /
- VS Code: Super + V
- Gemini: Super + G
- Firefox: Super + W
- Spotify: Super + S
- btop: Ctrl + Shift + Esc

### System (Hyprland)
- Fullscreen: Super + F
- Kill Window: Super + C
- App Launcher: Super + R
- Lock Screen: Super + L

## Installation
```bash
chmod +x setup.sh
./setup.sh
```

## Scripts
- `setup.sh`: Interactive installer with component selection
- `save_profile.sh`: Backup current config to repo
