function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        # Use 'z' (zoxide) to change directory so the database updates
        z "$cwd"
    end
    rm -f -- "$tmp"
end
