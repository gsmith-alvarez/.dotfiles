function fkill -d "Fuzzy kill processes"
    # List processes, fuzzy find, allow multi-selection (Tab), extract PID, and kill
    set -l pids (ps -ef | sed 1d | fzf -m \
        --header="[TAB] to multi-select, [ENTER] to kill" \
        --preview 'echo {}' \
        --preview-window down:3:wrap | awk '{print $2}')

    if test -n "$pids"
        echo $pids | xargs kill -9
        echo "💀 Killed PID(s): $pids"
    end
end
