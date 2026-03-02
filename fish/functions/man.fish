function man -d "Read man pages with bat formatting"
    # Set the MANPAGER environment variable just for this execution
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
    command man $argv
end
