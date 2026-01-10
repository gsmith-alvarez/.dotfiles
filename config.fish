### --- GLOBAL CONFIG --- ###

# 1. Fix Paths (Ensuring all quotes are closed)
# Add Homebrew to the PATH only if it exists, but append it to the END
if test -d /home/linuxbrew/.linuxbrew
    set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
    # Append to PATH instead of prepending
    set -q PATH; or set PATH ''
    set -gx PATH $PATH "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
    set -q MANPATH; or set MANPATH ''
    set -gx MANPATH $MANPATH "$HOMEBREW_PREFIX/share/man"
    set -q INFOPATH; or set INFOPATH ''
    set -gx INFOPATH $INFOPATH "$HOMEBREW_PREFIX/share/info"
end
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.local/bin" # Added missing quote here
fish_add_path "$HOME/.local/share/fnm" # Added path for fnm
fish_add_path "$HOME/.npm-global/bin"
fish_add_path /usr/lib/jvm/java-20-openjdk-amd64/bin
fish_add_path "$HOME/scripts" # This is my own little scripts


# WSL Paths
fish_add_path "/mnt/c/Users/Giova/AppData/Local/Programs/Microsoft VS Code/bin"
fish_add_path "/mnt/c/Program Files/MATLAB/R2025b/bin"

# 2. Environment Variables
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER bat
set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk-amd64
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# 3. Initialize Tools (Only if they exist)
type -q starship; and starship init fish | source
type -q zoxide; and zoxide init fish | source
type -q fzf; and fzf --fish | source

# Fix for the 'fnm not found' error
if type -q fnm
    fnm env --use-on-cd --shell fish | source
end

### --- INTERACTIVE CONFIG --- ###

if status is-interactive
    set -g fish_greeting
    fish_vi_key_bindings

    # Auto-start Zellij
    if not set -q ZELLIJ
        type -q zellij; and zellij
    end

    # Abbreviations
    abbr -a g git
    abbr -a gs 'git status'
    abbr -a ga 'git add'
    abbr -a gc 'git commit -m'
    abbr -a gp 'git push'
    abbr -a yr yazi
    abbr -a cd z
    abbr -a cat bat
    abbr -a find fd
    abbr -a gcan 'git commit --amend --no-edit'
    abbr -a du "dust -r"
    abbr -a cp "rsync -ah --progress"
    abbr -a mrun 'mold -run'
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a .... 'cd ../../..'
    abbr -a c code . # Open current directory in VS Code
    abbr -a cr code -r . # Open in current window (reuse)
    abbr -a cn code -n . # Open in a new window

    ## Asuscli Controller
    ### Power Profiles
    abbr -a pperf "asusctl profile -P Performance"
    abbr -a pbal "asusctl profile -P Balanced"
    abbr -a pquiet "asusctl profile -P Quiet"

    ### Battery Toggles
    abbr -a bmax "asusctl -c 100" # Use before a long flight/day out
    abbr -a bstay "asusctl -c 60" # Use for desk/office days 

    ## wl-copy
    abbr -a --set-cursor copy wl-copy
    abbr -a --set-cursor paste wl-paste

    ## eza
    abbr -a ls 'eza --icons --group-directories-first'
    abbr -a ll 'eza -lh --icons --grid --group-directories-first'
    abbr -a la 'eza -a --icons --group-directories-first'
    abbr -a tree 'eza --tree --icons'


    # Linker Variable
    set -gx LD /usr/local/bin/mold
    # 1. For C and C++ (Used by 'make', 'cmake', etc.)
    set -gx LDFLAGS "-fuse-ld=mold"

    # 2. For Rust (Used by 'cargo')
    set -gx RUSTFLAGS "-C link-arg=-fuse-ld=mold"

    # 3. Ensure your local bin takes priority
    fish_add_path -p ~/.local/bin

    # Completions
    complete -c y -w yazi
end

# argc-completions
set -gx ARGC_COMPLETIONS_ROOT /home/fall-of-baghdad/argc-completions
set -gx ARGC_COMPLETIONS_PATH "$ARGC_COMPLETIONS_ROOT/completions/linux:$ARGC_COMPLETIONS_ROOT/completions"
fish_add_path "$ARGC_COMPLETIONS_ROOT/bin"
# To add completions for only the specified command, modify next line e.g. set argc_scripts cargo git
set argc_scripts (ls -p -1 "$ARGC_COMPLETIONS_ROOT/completions/linux" "$ARGC_COMPLETIONS_ROOT/completions" | sed -n 's/\.sh$//p')
argc --argc-completions fish $argc_scripts | source
