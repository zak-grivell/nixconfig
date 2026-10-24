# Neovim editing setup

Neovim's editing and navigation keys remain native. The Space menu adds pickers,
code tools, and multiple cursors. Pause after Space to see the menu, or use
`Space ?` to open it explicitly.

## Appearance and Helix differences

The editor uses an opaque Catppuccin Frappé palette, matching Helix. Stylix's
Neovim target is disabled so it cannot replace the theme after startup. Syntax
uses plain text styles, and the buffer bar and statusline omit decorative icons,
close buttons, branch information, encoding and file-format labels.

Autosave, wrapping, relative numbers, diagnostics, signature help, syntax
selection, multiple cursors and language tools have Neovim equivalents here.
The editing model remains Vim's operator-first model; Helix's selection-first
commands and selection history are not emulated. Multiple cursors use the Space
menu described below. Helix grammar builds, queries, server feature priority and
some workspace/formatter settings are not imported; see path-lsp's limits below.
Language settings come from the flake; local `.helix/languages.toml` files are
ignored and do not trigger trust prompts.
Language servers must be available on PATH or in the project's allowed direnv
environment. `Space ch` shows the tools detected for the current buffer.

## Native keys

| Keys | Action |
| --- | --- |
| `grn` / `gra` | Rename / code action |
| `grr` / `gri` / `grt` | References / implementation / type definition |
| `gO` | Document symbols |
| `K` | LSP hover when an attached server supports it |
| `Ctrl-s` in Insert mode | Signature help |
| `[d` / `]d` | Previous / next diagnostic |
| `Ctrl-w d` | Diagnostic float |
| `[b` / `]b`, `:b`, `Ctrl-^` | Buffer navigation |
| `an` / `in` in Visual or Operator-pending mode | Grow / shrink syntax selection |
| `[n` / `]n` in Visual mode | Previous / next syntax node |
| `[N` / `]N` in Visual mode | Grow selection to adjacent siblings |
| `gc`, `gcc` | Native commenting |
| `Tab` | Accept completion when the menu is open; otherwise native snippet navigation / indentation |
| `Shift-Tab` | Native backward snippet navigation |

`gd` keeps its original local-declaration meaning; **`grd`** is the added LSP
definition shortcut. The old bare `gr` override has been removed so native
`gr…` shortcuts work without interference.

Completion uses `Ctrl-n` / `Ctrl-p` to select, `Tab` or `Ctrl-y` to accept, and
`Ctrl-Space` to request suggestions. These fall back to normal behaviour when
the completion menu is closed. Enter remains Enter.

## Added Vim-style editing

Tree-sitter text objects compose with Vim operators: `daf`, `cif`, `yac`, `via`.

| Object | Selection |
| --- | --- |
| `af` / `if` | Around / inside function |
| `ac` / `ic` | Around / inside class |
| `aa` / `ia` | Around / inside argument or parameter |

Surround uses `ys{motion}{character}`, `ds{character}`, and `cs{old}{new}`.
For example, `ysiw)` surrounds a word, `ds)` removes parentheses, and `cs)'`
changes parentheses to single quotes. Native `s`, `S`, and `f`/`t` are untouched.
Only mini.pairs supplies automatic bracket pairing; the duplicate autopairs and
comment plugins have been removed.

## Space menu

| Keys after Space | Action |
| --- | --- |
| `f` / `F` | Files in current working directory / project |
| `g` / `G` | Grep project / current working directory |
| `b` / `e` | Buffer picker / Oil file explorer |
| `s` / `S` | Document / workspace symbol picker |
| `d` / `D` | Trouble diagnostics panel / diagnostic picker |
| `j` | Flash jump |
| `ca` / `cr` / `cf` | Code action / rename / format |
| `ck` / `ch` / `cR` | Signature help / language health / reload language tools |
| `ua` / `uw` / `uh` / `ud` | Toggle autosave / wrap / inlay hints / diagnostics |

Files and grep respect ignore files and exclude `.direnv/`. Hidden files are
hidden by default. `Space f` uses Neovim's working directory (`:pwd`), while
`Space F` uses the detected language/project root.

## Multiple cursors

All permanent cursor mappings live under `Space m`; Vim's normal motions and
editing commands then operate across the cursors.

| Keys after Space m | Action |
| --- | --- |
| `n` / `N` | Add next / previous matching word or selection |
| `s` / `S` | Skip next / previous match |
| `a` | Add all matching occurrences |
| `j` / `k` | Add cursor below / above |
| `J` / `K` | Skip line below / above |
| `t` / `x` / `r` | Toggle / clear / restore cursors |
| `[` / `]` while cursors are active | Choose previous / next main cursor |
| `/` / `m` in Visual mode | Split selection by regex / match within selection |

Escape in Normal mode clears active extra cursors (or first reenables disabled
cursors). Its ordinary behaviour is unchanged when no extra cursors exist.

## Automatic behaviour

- Autosave is disabled by default; use `:w` to save. If enabled with `Space ua`,
  save named, writable modified files after 1.5 seconds without edits, and on
  application focus loss. Normal write hooks still run, including formatting.
- Unnamed, readonly, special, and unmodifiable buffers are skipped. Autosave
  waits while completion, snippets, or multiple-cursor editing are active.
- `:let b:autosave = v:false` disables saving for one buffer; `Space ua` toggles
  autosave globally. Saves never force an overwrite of externally changed files.
- Errors and warnings appear at the end of lines; the cursor line also shows
  full diagnostics below it. Native diagnostic navigation remains available.
- Signature help appears while typing function calls; supported symbols highlight
  on cursor idle. Inlay hints are opt-in through `Space uh`.
- Soft wrapping, a visible buffer bar, and relative line numbers are enabled.
  Neovim's default block/insert-bar cursor shapes remain unchanged.

Language tools and flake settings are documented in
[`path-lsp`](../packages/path-lsp/README.md).

Run `nix build .#checks.aarch64-darwin.nvim-workflow` to build and test the actual
configured editor, including plugin startup, map preservation, autosave,
Tree-sitter text objects, picker roots, and multiple cursors.
