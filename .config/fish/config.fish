### --- 1. INITIALIZATION --- ###
# We add all standard paths FIRST using -g (global append/prepend)
# so that our high-performance tools can overwrite them later.

fish_add_path -g ~/.local/bin

if test -d ~/.cargo/bin
    fish_add_path -g ~/.cargo/bin
end

if test -d /home/gsmith-alvarez/.lmstudio/bin
    fish_add_path -g /home/gsmith-alvarez/.lmstudio/bin
end

# Go (Only needed for dynamic go installs since mise manages the core binary)
if type -q go
    set -gx GOPATH (go env GOPATH)
    fish_add_path -g $GOPATH/bin
end

# LM Studio 
if test -d /home/gsmith-alvarez/.lmstudio/bin
    fish_add_path -g /home/gsmith-alvarez/.lmstudio/bin
end

### --- 2. THE ENGINE: MISE (Top Layer) --- ###
if type -q mise
    mise activate fish | source
end

### --- 3. CREDENTIALS --- ###
# GitHub Token (Note: synchronous lookups add shell startup latency)
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
    type -q navi; and navi widget fish | source

    # UI Preferences
    set -g fish_greeting
    fish_vi_key_bindings

    ### --- 3. ABBREVIATIONS --- ###

    # Navigation
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a cd z

    # Some Tools
    abbr -a cat bat
    abbr -a find fd
    abbr -a yr yazi
    abbr -a du "dust -r"
    abbr -a cp "rsync -ah --info=progress2"

    # Power Management Asus Laptop
    abbr -a pperf "asusctl profile set Performance"
    abbr -a pbal "asusctl profile set Balanced"
    abbr -a pquiet "asusctl profile set Quiet"
    abbr -a bbstay "asusctl battery limit 60"

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

    # Navi Keybinds
    if type -q navi
        # Bind to Alt+e (Escape + e in terminal talk)
        # This works in both default and vi-mode
        bind \ee _navi_smart_replace
        # If you use Fish VI mode, ensure it works in 'insert' mode too
        if functions -q fish_vi_key_bindings
            bind -M insert \ee _navi_smart_replace
        end
    end

    # Carapace Configuration
    if type -q carapace
        set -gx CARAPACE_BRIDGES 'zsh,bash,inshellisense,usage'
        carapace _carapace | source
    end

    # Wayland Clipboard
    abbr -a --set-cursor copy wl-copy
    abbr -a --set-cursor paste wl-paste

    complete -c y -w yazi
end
