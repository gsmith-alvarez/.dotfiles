### --- 1. ENVIRONMENT VARIABLES & PATHS --- ###

# Set Editor/Pager early
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER bat
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Java Configuration (Fixed version mismatch: PATH was 20, HOME was 21)
set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk-amd64

# Linker Variables (Moved to global so scripts/compilers can see them)
set -gx LD /usr/local/bin/mold
set -gx LDFLAGS "-fuse-ld=mold"
set -gx RUSTFLAGS "-C link-arg=-fuse-ld=mold"

# Homebrew Logic (Optimized)
if test -d /home/linuxbrew/.linuxbrew
    set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
    fish_add_path -a "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
    set -q MANPATH; or set MANPATH ''
    set -gx MANPATH $MANPATH "$HOMEBREW_PREFIX/share/man"
    set -q INFOPATH; or set INFOPATH ''
    set -gx INFOPATH $INFOPATH "$HOMEBREW_PREFIX/share/info"
end

# Consolidated Path Additions
# -p prepends (priority), -a appends
fish_add_path -p "$HOME/.local/bin" "$HOME/scripts"
fish_add_path -a "$HOME/.cargo/bin" "$HOME/.local/share/fnm" "$HOME/.npm-global/bin" "$JAVA_HOME/bin"

# Fish looks in your local folder BEFORE the system folder.
fish_add_path -p "$HOME/.local/bin" "$HOME/scripts"

# WSL Interop Paths (Only added if they exist)
if test -d /mnt/c/
    fish_add_path "/mnt/c/Users/Giova/AppData/Local/Programs/Microsoft VS Code/bin"
    fish_add_path "/mnt/c/Program Files/MATLAB/R2025b/bin"
end

### --- 2. TOOL INITIALIZATION --- ###

# Initialize fnm (Node manager)
if type -q fnm
    fnm env --use-on-cd --shell fish | source
end

# Initializing interactive-only tools
if status is-interactive
    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish | source
    type -q fzf; and fzf --fish | source

    # Keybindings & UI
    set -g fish_greeting
    fish_vi_key_bindings

    # Auto-start Zellij (Ensure it's not nested)
    if not set -q ZELLIJ; and type -q zellij
        eval zellij
    end

    ### --- 3. ABBREVIATIONS --- ###

    # General
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a .... 'cd ../../..'
    abbr -a cd z
    abbr -a cat bat
    abbr -a find fd
    abbr -a yr yazi
    abbr -a du "dust -r"
    abbr -a cp "rsync -ah --progress"
    abbr -a mrun 'mold -run'

    # Git
    abbr -a g git
    abbr -a gs 'git status'
    abbr -a ga 'git add'
    abbr -a gc 'git commit -m'
    abbr -a gp 'git push'
    abbr -a gcan 'git commit --amend --no-edit'

    # VS Code
    abbr -a c "code ."
    abbr -a cr "code -r ."
    abbr -a cn "code -n ."

    # Asuscli Controller (Zenbook Specific)
    abbr -a pperf "asusctl profile -P Performance"
    abbr -a pbal "asusctl profile -P Balanced"
    abbr -a pquiet "asusctl profile -P Quiet"
    abbr -a bmax "asusctl -c 100"
    abbr -a bstay "asusctl -c 60"

    # Clipboard (Wayland/Pop!_OS)
    abbr -a --set-cursor copy wl-copy
    abbr -a --set-cursor paste wl-paste

    # uv
    abbr -a py "uv run"
    abbr -a pyr "uv run python" #Interactive shell
    abbr -a pyv "uv venv"


    # Eza (Modern ls)
    if type -q eza
        abbr -a ls 'eza --icons --group-directories-first'
        abbr -a ll 'eza -lh --icons --grid --group-directories-first'
        abbr -a la 'eza -a --icons --group-directories-first'
        abbr -a tree 'eza --tree --icons'
    end

    # Completions wrapper
    complete -c y -w yazi
end

### --- 4. ARGC COMPLETIONS (PERFORMANCE TUNED) --- ###

set -gx ARGC_COMPLETIONS_ROOT "$HOME/argc-completions"
if test -d "$ARGC_COMPLETIONS_ROOT"
    set -gx ARGC_COMPLETIONS_PATH "$ARGC_COMPLETIONS_ROOT/completions/linux:$ARGC_COMPLETIONS_ROOT/completions"
    fish_add_path "$ARGC_COMPLETIONS_ROOT/bin"

    # Avoid running ls/sed on every shell start. 
    # Only source if in interactive mode and argc exists.
    if status is-interactive; and type -q argc
        # Manually list your most used commands here for speed, 
        # or keep the dynamic loop if you don't mind a 10-20ms delay.
        set -l argc_scripts cargo git asusctl brew
        argc --argc-completions fish $argc_scripts | source
    end
end
