# Radical CLI Workflow Optimizations

This document outlines the advanced, AI-augmented, and context-aware CLI functions implemented to significantly enhance productivity and reduce cognitive load in your Fish shell environment.

## Core Principles
- **Pattern Recognition & Redundancy:** Abstracting repetitive tasks into intelligent functions.
- **Integration Opportunities:** Leveraging modern CLI tools like `fzf`, `jq`, `ripgrep`, `delta`, `bat`, `sd`, `watchexec`, and `zellij`.
- **Context-Aware Automations:** Functions anticipating next moves based on directory or Git branch state.
- **Modernization:** Replacing legacy patterns with performant, forward-thinking alternatives.
- **The Unconventional:** Integrating AI-piping and cross-tool hooks to challenge standard CLI conventions.

## New Functions & Aliases

### `s` (Unified Multi-Modal Search)
A powerful interface leveraging `fzf` to dynamically switch between `ripgrep` (text search), `ripgrep-all` (document search), and `fd` (filename search). It offers instant previews, direct `nvim` integration (opening to a specific line or populating the quickfix list for multiple selections), and `xdg-open` for external viewing. This function replaces `rgf`, `sg`, `rga-fzf`, `nvq`, and `peek`.
`s [query]`

### `q` (Omni-query: JSON/YAML/TOML/JSONL)
A universal query shortcut that automatically detects file formats (JSON, YAML, TOML) or piped input. It uses `yq` for powerful parsing and `gojq` for superior colorization and interactive exploration. Can also launch `fzf` to pick a config file.
`q [query] [file]`
`cat config.toml | q '.version'`

### `openf` (Intelligent File Opener)
Fuzzy-finds files and opens them intelligently based on file type (e.g., `nvim` for code, `ouch view` for archives, `yazi` for others).
`openf`

### `aicommits` (AI Git Commit Message Generator)
Generates a conventional Git commit message for staged changes using `aider-chat`, offering a chance to accept or edit.
`aicommits`

### `zs` (Smart Zellij Session Manager)
Manages `zellij` sessions with flexible layout options. Attaches to or creates a project-named session. Can launch a specialized "dashboard" layout for monitoring (`zs dashboard`) or a system "health" dashboard (`zs health`), or use custom layouts (`zs <custom_layout_name>`).
`zs`
`zs dashboard`
`zs health`
`zs <custom_layout_name>`

### `json_query` (Interactive JSON Query Tool)
Pipes JSON output to `fzf` and `gojq` for interactive exploration and extraction of data.
`some_command_output | json_query`

### `smart_navi_add` (Cheatsheet Addition)
Adds new commands and their descriptions to your dynamic `navi` cheatsheet, automating cheatsheet maintenance.
`smart_navi_add "<command>" "<description>"`

### `git_smart_checkout` (AI-Augmented Fuzzy Git Checkout)
Combines `fzf` for fuzzy branch selection with `git_branch_ai_summary` to show an AI-generated summary of changes for a selected branch *before* you check it out, reducing cognitive load during context switching.
`git_smart_checkout`

### `git_sdiff` (Structural Git Diff)
Leverages `difftastic` for syntax-aware Git diffs, providing semantic changes for code review rather than just line-based differences. Also available via the `git sdiff` alias (requires `.gitconfig` setup).
`git_sdiff [files...]`

### `__on_pwd_change` (Context-aware Project Initialization)
A silent, event-driven function that automatically triggers when you change directories (`cd`). It renames your current Zellij tab to the project name (if in a Git repo) and proactively notifies you if a project-specific Zellij layout (`<project_name>.kdl`) exists, prompting you to use `zs`.

### `log_analyzer` (AI-powered Log Analysis with Safety Filter)
Pipes log content (e.g., from `journalctl`, `tail`) to `aider-chat` for AI-powered identification of critical errors, patterns, and suggested resolutions, automatically filtering large inputs.
`some_log_command | log_analyzer`

### `cheat` (Unified Command Help)
A smart function that first attempts to provide concise usage examples via `tldr`, falling back to a `bat`-enhanced `man` page if a `tldr` page is not available. This offers layered access to command documentation.
`cheat <command>`

## New CLI Tools
- `difftastic`: A structural diff tool that understands code syntax for more intelligent comparisons.
- `yq`: A portable `jq` for querying and manipulating YAML, XML, TOML, and other structured data formats.
- `dog`: A modern, user-friendly command-line DNS client, an intuitive alternative to `dig`.
- `procs`: A modern replacement for `ps`, offering enhanced process information with better readability.

## General Aliases/Improvements
- `abbr -a grep rg`: Aliases `grep` to `ripgrep` for faster searching.
- `.gitconfig` additions: Configuration for `delta` for enhanced Git diff viewing.

## Activation
To ensure all changes are active:
1. Run `mise install` (to install `delta` and other `mise`-managed tools).
2. Manually apply the `.gitconfig` changes provided earlier.
3. Restart your `fish` shell or run `source ~/.config/fish/config.fish`.
