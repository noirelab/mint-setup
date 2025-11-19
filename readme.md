# Linux Mint Setup

This repository contains configuration files and scripts for setting up a customized Linux Mint environment.

## Applications
    - Kitty: Terminal Emulator
    - Discord: Voice and Text Chat
    - Visual Studio Code: Code Editor
    - Gemini: AI Chatbot
    - Firefox: Web Browser
    - Spotify: Music Streaming
    - Nemo: File Manager
    - btop: System Monitor
    - Docker: Containerization platform (Engine + Compose)
    - Miniconda3: Python package and environment manager
    - Atuin: Better shell history
    - Windows Opacity: Opacify windows based on focus and state
## Configuration Files
    - `kitty/`: Kitty terminal configuration with Ayu theme
    - `scripts/.bashrc`: Enhanced bash configuration with aliases, functions, and integrations
    - `scripts/opacify_windows.sh`: Window opacity management script
    - `setup.sh`: Interactive setup script with component-based installation

## Keyboard Shortcuts
### Applications
    - Kitty (terminal): Super + Enter (fullscreen)
    - Discord: Super + /
    - Visual Studio Code: Super + V
    - Gemini: Super + G
    - Firefox: Super + W
    - Spotify: Super + S
    - btop (Task Manager): Ctrl + Shift + Esc

### System
    - Screenshot: Super + Shift + S
    - Fullscreen: Super + F
    - Minimize: Super + M
    - Maximize/Restore: Super + Shift + M
    - Toggle desktop icons: Ctrl + Alt + I

## Scripts
    - `opacify_windows.sh`: Automatically adjusts window opacity based on focus and state


## Installation
Run the setup script to install and configure all components:
```bash
chmod +x setup.sh
./setup.sh
```

## Features
- Custom Kitty terminal with Ayu theme
- Enhanced bash configuration with useful aliases and functions
- Window opacity management for better visual focus
- Pre-configured keyboard shortcuts for productivity
- Docker containerization with buildx and compose plugins
- Miniconda3 for Python development
- Atuin for enhanced shell history with sync capabilities
- Interactive setup script with per-component installation
- Automatic shortcut configuration for both GNOME and Cinnamon
- Startup integration for window opacity effects

## Dependencies
The setup script will automatically install required dependencies:
- xdotool, wmctrl: Window management for opacity script
- gnome-screenshot: Screenshot functionality
- btop: System monitoring
- git, nala, curl, wget: System utilities
