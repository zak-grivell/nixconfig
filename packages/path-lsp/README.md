# path-lsp

A Neovim plugin packaged with Nix. Reads the pinned `helix-unwrapped` source's
`languages.toml`, then merges Helix language settings declared in the flake.
Project-local `.helix/languages.toml` files are ignored, with no trust prompts.
No server or formatter downloads at runtime.

The home module passes `programs.helix.languages` as personal overrides. Other
users can call this package with `helixOverrides = { ... };`.

## Usage

Build with `nix build .#path-lsp`; the Nixvim home module installs and configures
it automatically. Standalone users add the resulting plugin to Neovim's runtime
path, install conform.nvim, and call `require('path-lsp').setup()`.

Install tools globally through Nix or expose them in a project direnv environment.
Servers attach when a matching file is opened and their executable is available.
Missing tools are skipped. When `.envrc` or `.env` exists in the file directory or
its ancestors, path-lsp obtains the environment with `direnv exec <directory>`.
A blocked environment is reported and tools are not started for that buffer.
It never runs `direnv allow` or changes your direnv files.

- `:PathLspHealth`: language, root, servers, formatter, parser, and environment errors.
- `:PathLspReload`: refresh the environment and reattach loaded buffers.
  Run after changing PATH or direnv. Rebuild the editor for flake language changes.
- `:PathLspFormat`: format this buffer using its external formatter, then LSP fallback.
- Saving formats automatically unless the language has `auto-format = false`.

Declare language, server, formatter and indentation overrides in
`programs.helix.languages` in the flake; both editors use those settings.
Maps merge recursively, lists replace, and language entries merge by name.

## Grammar support and limits

`grammar = "python"` selects an already installed Neovim Tree-sitter parser.
Flake-defined custom languages can specify file extensions or `{ glob = "..." }` entries in
`file-types`, server commands, indentation, and an installed grammar. Helix's
`[[grammar]]` source/build definitions are not compiled or downloaded. Install
additional compatible parsers through Nixvim. Helix query files and project
Tree-sitter query overrides are not imported.

This adapts tool configuration, not every Helix editor setting. Root markers,
server arguments, environment, initialization options, language IDs, common
server feature filters, formatter commands and `%{buffer_name}` are translated.
Helix-only UI settings, feature priority between multiple servers, custom
workspace roots, and formatter expansions other than `%{buffer_name}` are not
emulated. A PATH executable check cannot guarantee an interpreter-launched server
has all its packages installed. If several configured servers are present, they
may all attach, as configured in Helix; use the flake's `language-servers` to choose.

Run `nix build .#checks.aarch64-darwin.path-lsp` for the integration tests.
Helix language defaults are MPL-2.0; this package uses the same license.
