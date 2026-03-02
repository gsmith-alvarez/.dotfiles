# --- CONFIGURATION ---
set -g ZJ_TUI_APPS nvim spotify-player surge btop lazygit yazi
set -g ZJ_FUN_ICONS "✨" "🌈" "🦄" "🎀" "🌸" "🍭"

# 1. THE ADORABLE NOTIFIER
function __zj_notify -d "Renders a cute, colorful notification"
    set -l msg $argv[1]
    set -l color $argv[2]; or set color magenta

    # Pick a random icon for extra sparkliness
    set -l icon (random choice $ZJ_FUN_ICONS)

    echo (set_color $color)"$icon [Shell-chan]: "(set_color normal)"$msg"
end

# 2. EVENT: Directory Change
function __on_pwd_change --on-variable PWD
    test "$PWD" = "$HOME" -o "$PWD" = /; and return

    set -l folder (basename $PWD)
    set -l layout "$HOME/.config/zellij/layouts/$folder.kdl"

    if test -f "$layout"
        __zj_notify "Ooh! I found a special layout for $folder! Use it? ฅ(^◕ᴥ◕^)" yellow
    else
        # Just a small vibe check
        __zj_notify "Wandered into $folder... Looks cozy! 🏡" cyan
    end
end

# 3. EVENT: Pre-execution (The Hype-Man)
function __zj_preexec_handler --on-event fish_preexec
    set -q ZELLIJ; or return

    set -l original_cmd $argv[1]
    set -l bin (string replace -r '^(sudo|doas|command|builtin)\s+' '' $original_cmd | cut -d' ' -f1)

    if contains -- $bin $ZJ_TUI_APPS
        set -l greetings \
            "Good luck with $bin! You got this! 💪" \
            "Time to get comfy in $bin... ☕" \
            "Launching $bin. Make something cool! 🎨" \
            "Entering the $bin dimension... 🌌"

        __zj_notify (random choice $greetings) green
    end
end

# 4. EVENT: Post-execution (The Welcome Home)
function __zj_postexec_handler --on-event fish_postexec
    set -q ZELLIJ; or return

    set -l last_cmd (string split " " $argv[1])[1]
    if contains -- $last_cmd $ZJ_TUI_APPS
        set -l welcomes \
            "Welcome back! How was it? 🧸" \
            "Missed you! What's our next move? 🐾" \
            "Back in the driver's seat. Let's go! 🏎️" \
            "Told you you'd be back. 😉"

        __zj_notify (random choice $welcomes) magenta
    end
end
