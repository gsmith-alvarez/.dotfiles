### --- 1. INITIALIZATION --- ###
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin

if type -q mise
    mise activate fish | source
end

# GitHub Token (Keeping your existing keyring logic)
if command -v secret-tool >/dev/null
    set -gx GITHUB_TOKEN (secret-tool lookup github token)
    set -gx GH_TOKEN $GITHUB_TOKEN
end

### --- 2. INTERACTIVE ONLY --- ###

if status is-interactive
    # mise handles the PATH, so these inits are now much faster
    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish | source
    type -q fzf; and fzf --fish | source
    type -q atuin; and atuin init fish | source

    # UI Preferences
    set -g fish_greeting
    fish_vi_key_bindings

    ### --- 3. ABBREVIATIONS --- ###

    # Navigation
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a cd z
    abbr -a cat bat
    abbr -a find fd
    abbr -a yr yazi
    abbr -a du "dust -r"
    abbr -a cp "rsync -ah --info=progress2"

    # Power Management Asus Laptop
    abbr -a pperf "asusctl profile set Performance"
    abbr -a pbal "asusctl profile set Balanced"
    abbr -a pquiet "asusctl profile set Quiet"
    abbr -a bbstay "asusctl -c 60"

    # Git
    abbr -a g git
    abbr -a gs 'git status'
    abbr -a ga 'git add'
    abbr -a gc 'git commit -m'
    abbr -a gp 'git push'

    # Package Management
    abbr -a top 'topgrade --cleanup'

    # Python (uv)
    abbr -a py "uv run"
    abbr -a pyr "uv run python"
    abbr -a pyv "uv venv"

    # Modern LS (eza)
    if type -q eza
        abbr -a ls 'eza --icons --group-directories-first'
        abbr -a ll 'eza -lh --icons --grid --group-directories-first'
        abbr -a la 'eza -a --icons --group-directories-first'
        abbr -a tree 'eza --tree --icons'
    end

    # Wayland Clipboard
    abbr -a --set-cursor copy wl-copy
    abbr -a --set-cursor paste wl-paste

    complete -c y -w yazi
end
