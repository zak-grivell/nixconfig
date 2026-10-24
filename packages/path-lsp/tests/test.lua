vim.opt.runtimepath:prepend(vim.env.PATH_LSP_PLUGIN)
vim.opt.runtimepath:prepend(vim.env.PATH_LSP_CONFORM)
local plugin = require('path-lsp')
local temp = vim.fn.tempname()
vim.fn.mkdir(temp, 'p')
local function write(path, content)
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  vim.fn.writefile(vim.split(content, '\n', { plain = true }), path)
end
local function eq(actual, expected)
  assert(vim.deep_equal(actual, expected), vim.inspect({ actual = actual, expected = expected }))
end
local defaults = vim.json.decode(table.concat(vim.fn.readfile(vim.env.PATH_LSP_PLUGIN .. '/languages.json'), '\n'))
assert(#defaults.defaults.language > 100, 'must import real Helix defaults')
plugin._validate(plugin._merge(defaults.defaults, defaults.overrides))
local python = vim.fn.exepath('python3')
local server = vim.env.PATH_LSP_TESTS .. '/server.py'
local envlog = temp .. '/environment.log'
local data = {
  defaults = {
    language = {{ name = 'python', ['file-types'] = { 'py' }, roots = { 'pyproject.toml' },
      ['language-servers'] = { 'test', 'missing' }, ['auto-format'] = true,
      indent = { ['tab-width'] = 4, unit = '    ' }, grammar = 'python' }},
    ['language-server'] = {
      test = { command = python, args = { server }, config = { original = true } },
      missing = { command = 'path-lsp-server-that-does-not-exist' },
    },
  },
  overrides = {
    ['language-server'] = { test = { config = { personal = true } } },
    language = {
      { name = 'python', formatter = { command = python,
        args = { '-c', 'import sys; sys.stdout.write(sys.stdin.read().upper())', '%{buffer_name}' } } },
      { name = 'custom', ['file-types'] = { 'special' }, grammar = 'lua',
        ['language-servers'] = {}, ['auto-format'] = false,
        indent = { ['tab-width'] = 2, unit = '  ' } },
      { name = 'unconfigured', ['file-types'] = { 'empty' }, ['language-servers'] = { 'empty' } },
    },
  },
}
data.defaults['language-server'].empty = {
  command = python, args = { server }, environment = { PATH_LSP_LOG = temp .. '/empty.log' },
}
write(temp .. '/data.json', vim.json.encode(data))
local a, b = temp .. '/a', temp .. '/b'
local function project(root, tag, indent)
  write(root .. '/pyproject.toml', '')
  write(root .. '/.helix/languages.toml', ([=[
[[language]]
name = "python"
indent = { tab-width = %d, unit = "%s" }
formatter = { command = "%s", args = ["-c", "import sys; sys.stdout.write(sys.stdin.read().upper())", "%%{buffer_name}"] }
[language-server.test.config]
project = "%s"
[language-server.test.environment]
PATH_LSP_LOG = "%s/messages.log"
]=]):format(indent, string.rep(' ', indent), python, tag, root))
end
project(a, 'a', 2)
project(b, 'b', 8)
local real_secure_read = vim.secure.read
vim.secure.read = function()
  error('project-local config must never be read or prompt for trust')
end
plugin.setup({ data = temp .. '/data.json' })
local function open(path)
  write(path, 'hello')
  vim.cmd.edit(vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()
  plugin.attach(buf)
  vim.wait(200, function() return false end, 10)
  return buf
end
local first = open(a .. '/first.py')
assert(vim.wait(5000, function()
  local clients = vim.lsp.get_clients({ bufnr = first })
  return #clients == 1 and clients[1].initialized
end), 'first LSP must initialize')
eq(vim.bo[first].shiftwidth, 4)
eq(plugin.health(first).servers[2].available, false)
eq(plugin.health(first).language.indent.unit, '    ')
local first_client = vim.lsp.get_clients({ bufnr = first })[1]
eq(first_client.config.init_options, { original = true, personal = true })
local second = open(a .. '/second.py')
eq(#vim.lsp.get_clients({ bufnr = second }), 1)
eq(vim.lsp.get_clients({ bufnr = second })[1].id, first_client.id)
local third = open(b .. '/third.py')
assert(vim.wait(5000, function()
  local clients = vim.lsp.get_clients({ bufnr = third })
  return #clients == 1 and clients[1].initialized
end))
local third_client = vim.lsp.get_clients({ bufnr = third })[1]
assert(third_client.id ~= first_client.id, 'projects must not share a client')
eq(third_client.config.init_options, { original = true, personal = true })
eq(vim.bo[third].shiftwidth, 4)
-- Exercise actual Conform execution and stdin/stdout, not a mock formatter.
local opts = plugin.format_options(third, false)
local format_error
require('conform').format(opts, function(err) format_error = err end)
assert(not format_error, tostring(format_error))
eq(vim.api.nvim_buf_get_lines(third, 0, -1, false), { 'HELLO' })
local formatter_config = require('conform').formatters[plugin.health(third).formatter_name]
eq(formatter_config.args(nil, { filename = b .. '/third.py' })[3], b .. '/third.py')
-- Lists, including an empty server list, replace instead of concatenating.
eq(plugin._merge(data.defaults, { language = {{ name = 'python', ['language-servers'] = {} }} }).language[1]['language-servers'], {})
local custom = { language = {{ name = 'custom', ['file-types'] = {{ glob = '*.special' }} }} }
eq(plugin._language_for(custom, '/tmp/test.special', third).name, 'custom')
-- A fake direnv exercises nested environments and refusal without changing trust files.
local bin = temp .. '/bin'
write(bin .. '/direnv', '#!/bin/sh\ncase "$2" in\n*/blocked) echo "environment is blocked" >&2; exit 1;;\nesac\nprintf "PATH=' .. bin .. ':$PATH\\000PATH_LSP_NESTED=yes\\000"\necho "$2" >> "' .. envlog .. '"')
vim.fn.setfperm(bin .. '/direnv', 'rwxr-xr-x')
write(bin .. '/project-lsp', '#!/bin/sh\nexec "' .. python .. '" "' .. server .. '"')
vim.fn.setfperm(bin .. '/project-lsp', 'rwxr-xr-x')
vim.env.PATH = bin .. ':' .. vim.env.PATH
write(a .. '/nested/.envrc', '# fixture, never allowed or executed')
local nested = open(a .. '/nested/file.py')
eq(plugin.health(nested).env.PATH_LSP_NESTED, 'yes')
eq(vim.fn.readfile(envlog)[1], a .. '/nested')
eq(plugin._executable('project-lsp', plugin.health(nested).env, a), bin .. '/project-lsp')
write(a .. '/blocked/.envrc', '# blocked fixture')
local blocked = open(a .. '/blocked/file.py')
assert(plugin.health(blocked).error:find('environment is blocked', 1, true))
eq(#vim.lsp.get_clients({ bufnr = blocked }), 0)
eq(plugin.format_options(blocked, true), nil)
eq(plugin._executable('missing', { PATH = bin }, a), nil)
-- Editing local settings has no effect, including after an explicit reload.
write(b .. '/.helix/languages.toml', '[[language]]\nname = "python"\nauto-format = false\nlanguage-servers = []')
plugin.reload()
assert(plugin.format_options(third, true))
assert(plugin.format_options(third, false))
assert(vim.wait(5000, function()
  local clients = vim.lsp.get_clients({ bufnr = third })
  return #clients == 1 and clients[1].initialized
end), 'LSP must reattach after environment reload')
-- A flake-defined language chooses an installed grammar; local overrides are ignored.
local grammar_project = temp .. '/grammar'
write(grammar_project .. '/.helix/languages.toml', [=[
[[language]]
name = "unwanted-local-language"
file-types = ["special"]
grammar = "missing-local-parser"
language-servers = []
indent = { tab-width = 2, unit = "  " }
]=])
local grammar_buffer = open(grammar_project .. '/example.special')
eq(plugin.health(grammar_buffer).language.name, 'custom')
eq(plugin.health(grammar_buffer).grammar, 'lua')
eq(plugin.health(grammar_buffer).grammar_available, true)
eq(vim.bo[grammar_buffer].filetype, 'custom')
-- Flake auto-format=false suppresses saving, but permits manual formatting.
eq(plugin.format_options(grammar_buffer, true), nil)
assert(plugin.format_options(grammar_buffer, false))
-- Invalid local settings are ignored too.
write(grammar_project .. '/.helix/languages.toml', '[[language]]\nname = "python"\nformatter = "invalid"')
local invalid_buffer = open(grammar_project .. '/invalid.py')
eq(plugin.health(invalid_buffer).language.formatter.command, python)
vim.secure.read = real_secure_read
-- Servers without config must receive an object, not the Lua empty-table array.
local empty_buffer = open(temp .. '/unconfigured/file.empty')
assert(vim.wait(5000, function()
  local clients = vim.lsp.get_clients({ bufnr = empty_buffer })
  return #clients == 1 and clients[1].initialized
end), 'server without settings must initialize')
local initialize
for _, line in ipairs(vim.fn.readfile(temp .. '/empty.log')) do
  local message = vim.json.decode(line)
  if message.method == 'initialize' then initialize = message end
end
assert(initialize, 'initialize request must reach the server')
eq(vim.json.encode(initialize.params.initializationOptions), '{}')
eq(vim.json.encode(vim.lsp.get_clients({ bufnr = empty_buffer })[1].config.settings), '{}')
for _, client in ipairs(vim.lsp.get_clients()) do client:stop(true) end
vim.fn.delete(temp, 'rf')
print('path-lsp: integration tests passed')
