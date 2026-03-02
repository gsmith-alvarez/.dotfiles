function fkill -d "Fuzzy kill processes"
    # List processes, fuzzy find, allow multi-selection (Tab), extract PID, and kill
    set -l pids (ps -ef | sed 1d | fzf -m \
        --header="[TAB] to multi-select, [ENTER] to kill" \
        --preview 'echo {}' \
        --preview-window down:3:wrap | awk '{print $2}')

    if test -n "$pids"
        # Graceful SIGTERM first, then SIGKILL for anything that survives
        echo $pids | xargs kill -15
        sleep 2
        echo $pids | xargs kill -9 2>/dev/null
        echo "💀 Killed PID(s): $pids"
    end
end
