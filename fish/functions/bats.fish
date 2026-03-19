function bats
    # If arguments were passed, use them. Otherwise, default to *.bats
    if count $argv >/dev/null
        env BATS_RUN_SKIPPED=true command bats $argv
    else
        env BATS_RUN_SKIPPED=true command bats *.bats
    end
end
