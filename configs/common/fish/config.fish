source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting

end

#######################################################
# ALIASES (Fish style)
#######################################################
alias cls='clear'
alias nala='sudo nala install'

# Modern tools
alias ls='eza -aF --color=always'
alias cat='bat'
alias grep='rg' # Assumes ripgrep is installed based on your script

#######################################################
# FUNCTIONS
#######################################################

# Create and go to directory
function mkdirg
    mkdir -p $argv[1]
    cd $argv[1]
end

# Auto 'ls' after 'cd'
function cd
    builtin cd $argv
    ls
end

#######################################################
# INITIALIZATION
#######################################################

# Start Starship
starship init fish | source

# Conda Initialization
if test -f /home/noirelab/miniconda3/bin/conda
    eval /home/noirelab/miniconda3/bin/conda "shell.fish" "hook" $argv | source
end