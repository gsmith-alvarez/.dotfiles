# VS Code Exhaustive Workflow Cheat Sheet

## Window, Split & Terminal Management

| Key Chord | Action / Command | Context (When) | Origin |
| --- | --- | --- | --- |
| `<C-h>` | `workbench.action.navigateLeft` | Global | `keybindings.json` |
| `<C-l>` | `workbench.action.navigateRight` | Global | `keybindings.json` |
| `<C-k>` | `workbench.action.navigateUp` | Global | `keybindings.json` |
| `<C-j>` | `workbench.action.navigateDown` | Global | `keybindings.json` |
| `<C-w> v` | `workbench.action.splitEditor` | Global | `keybindings.json` |
| `<C-w> s` | `workbench.action.splitEditorDown` | Global | `keybindings.json` |
| `<C-w> q` | `workbench.action.closeActiveEditor` | Global | `keybindings.json` |
| `<C-backtick>` | `workbench.action.terminal.toggleTerminal` | Global | `keybindings.json` |

## Editor Navigation & Vim Motions (VSCodeVim/Neovim specifics)

| Key Chord | Action / Command | Context (When) | Origin |
| --- | --- | --- | --- |
| `<Leader>` | `vspacecode.space` | `editorTextFocus && vim.mode != 'Insert'` | `keybindings.json` |
| `<Leader>` | `vspacecode.space` | Normal Mode / Visual Mode | `settings.json` (Vim config) |
| `,` | `vspacecode.space` -> `whichkey.triggerKey "m"` | Normal Mode / Visual Mode | `settings.json` (Vim config) |
| `>` | `editor.action.indentLines` | Visual Mode | `settings.json` (Vim config) |
| `<` | `editor.action.outdentLines` | Visual Mode | `settings.json` (Vim config) |

## Code Intelligence (LSP, Go To, Hover, Refactor)

| Key Chord | Action / Command | Context (When) | Origin |
| --- | --- | --- | --- |
| `<C-j>` | `selectNextSuggestion` | `suggestWidgetVisible` | `keybindings.json` |
| `<C-k>` | `selectPrevSuggestion` | `suggestWidgetVisible` | `keybindings.json` |
| `<C-l>` | `acceptSelectedSuggestion` | `suggestWidgetVisible` | `keybindings.json` |
| `<C-j>` | `showNextParameterHint` | `parameterHintsVisible` | `keybindings.json` |
| `<C-k>` | `showPrevParameterHint` | `parameterHintsVisible` | `keybindings.json` |
| `<C-j>` | `selectNextCodeAction` | `codeActionMenuVisible` | `keybindings.json` |
| `<C-k>` | `selectPrevCodeAction` | `codeActionMenuVisible` | `keybindings.json` |
| `<C-l>` | `acceptSelectedCodeAction` | `codeActionMenuVisible` | `keybindings.json` |

## PlatformIO & Embedded Toolchain (`<Leader> e` namespace)

| Key Chord | Action / Command | Context (When) | Origin |
| --- | --- | --- | --- |
| `<Leader> e b` | Build Firmware (`PIO: Build`) | VSpaceCode Menu | VSpaceCode Override (`settings.json`) |
| `<Leader> e u` | Upload to Board (`PIO: Upload`) | VSpaceCode Menu | VSpaceCode Override (`settings.json`) |
| `<Leader> e m` | Serial Monitor (`PIO: Monitor`) | VSpaceCode Menu | VSpaceCode Override (`settings.json`) |
| `<Leader> e c` | Update Compile DB (`PIO: Generate Compilation DB`) | VSpaceCode Menu | VSpaceCode Override (`settings.json`) |

## Version Control (Magit/Git)

| Key Chord | Action / Command | Context (When) | Origin |
| --- | --- | --- | --- |
| `x` | `magit.discard-at-point` | Magit Buffer | `keybindings.json` |
| `-` | `magit.reverse-at-point` | Magit Buffer | `keybindings.json` |
| `<S-->` | `magit.reverting` | Magit Buffer | `keybindings.json` |
| `<S-o>` | `magit.resetting` | Magit Buffer | `keybindings.json` |
| `y` | `vspacecode.showMagitRefMenu` | Magit Buffer (Normal Mode) | `keybindings.json` |
| `g` | `vspacecode.showMagitRefreshMenu` | Magit Buffer | `keybindings.json` |

## QuickOpen & File Explorer Navigation

| Key Chord | Action / Command | Context (When) | Origin |
| --- | --- | --- | --- |
| `<C-j>` | `workbench.action.quickOpenSelectNext` | `inQuickOpen` | `keybindings.json` |
| `<C-k>` | `workbench.action.quickOpenSelectPrevious` | `inQuickOpen` | `keybindings.json` |
| `<C-h>` | `file-browser.stepOut` | `inFileBrowser` | `keybindings.json` |
| `<C-l>` | `file-browser.stepIn` | `inFileBrowser` | `keybindings.json` |

## VSpaceCode Core (Leader Menus - Default)

*Note: These are standard VSpaceCode bindings accessible via `<Leader>`.*

| Key Chord | Action / Command | Context (When) | Origin |
| --- | --- | --- | --- |
| `<Leader> f` | File Menu | Normal / Visual | VSpaceCode Default |
| `<Leader> b` | Buffer Menu | Normal / Visual | VSpaceCode Default |
| `<Leader> p` | Project Menu (Native) | Normal / Visual | VSpaceCode Default |
| `<Leader> s` | Search Menu | Normal / Visual | VSpaceCode Default |
| `<Leader> g` | Git Menu | Normal / Visual | VSpaceCode Default |

---

### 💡 Architectural Notes

*   **PlatformIO Namespace:** Relocated to `<Leader> e` (Embedded) to prevent collision with VSpaceCode's native `<Leader> p` (Project) menu.
*   **Vim Handoff:** Spacebar is explicitly passed to VSpaceCode via `keybindings.json` to prevent the Vim extension from swallowing the trigger.
*   **Magit 'x':** Remapped to discard-at-point for Vim consistency.
