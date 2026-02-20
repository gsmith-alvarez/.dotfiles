### --- 1. ENVIRONMENT VARIABLES & PATHS (Aqua First) --- ###

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER bat
# Enhanced Manpages with bat
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

set -gx AQUA_ROOT_DIR "$HOME/.local/share/aquaproj-aqua"

# Performance Linker (mold) - Pointing to aqua's bin
set -gx LD mold
set -gx LDFLAGS "-fuse-ld=mold"
set -gx RUSTFLAGS "-C link-arg=-fuse-ld=mold"

# CLEAN PATH LOGIC (Priority Order)
# 1. Aqua (Highest priority to override system binaries)
fish_add_path -p "$HOME/.local/share/aquaproj-aqua/bin"

# 2. Local Scripts & General Binaries
fish_add_path -p "$HOME/.local/bin" "$HOME/scripts"

# 3. Development Runtimes (Appended)
fish_add_path -a "$HOME/.cargo/bin" "$HOME/.local/share/fnm"

# GitHub Token (Keeping your existing keyring logic)
if command -v secret-tool >/dev/null
    set -gx GITHUB_TOKEN (secret-tool lookup github token)
    set -gx GH_TOKEN $GITHUB_TOKEN
end

### --- 2. INTERACTIVE ONLY --- ###

if status is-interactive
    # Instant initialization - only run if command exists
    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish | source
    type -q fzf; and fzf --fish | source
    type -q fnm; and fnm env --use-on-cd --shell fish | source
    type -q atuin; and atuin init fish | source

    # UI Preferences
    set -g fish_greeting

    fish_vi_key_bindings


    ### --- 3. ABBREVIATIONS (The Workflow) --- ###

    # Navigation & Fundamentals
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a cd z
    abbr -a cat bat
    abbr -a find fd
    abbr -a yr yazi
    abbr -a du "dust -r"
    abbr -a cp "rsync -ah --info=progress2"

    # Git (Streamlined)
    abbr -a g git
    abbr -a gs 'git status'
    abbr -a ga 'git add'
    abbr -a gc 'git commit -m'
    abbr -a gp 'git push'

    # Package Management
    abbr -a top 'topgrade --cleanup'
    abbr -a aq aqua
    abbr -a aqi 'aqua i'

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
