local function eq(actual, expected)
  assert(vim.deep_equal(actual, expected), vim.inspect({ actual = actual, expected = expected }))
end
local function run()
  local workflow = require('editor-workflow')
  local temp = vim.fn.tempname()
  vim.fn.mkdir(temp .. '/project/subdir', 'p')
  vim.fn.mkdir(temp .. '/project/.git', 'p')
  local function edit(name, contents)
    vim.fn.writefile(contents, name)
    vim.cmd.edit(vim.fn.fnameescape(name))
    return vim.api.nvim_get_current_buf()
  end
  local function mapping(key, mode)
    return vim.fn.maparg(key, mode or 'n', false, true)
  end
  -- The actual generated Nixvim package must preserve native editing/LSP maps.
  for _, key in ipairs({ 'h', 'j', 'k', 'l', 's', 'S', 'x', 'X', 'gd', 'gr', 'n', 'N', '/', 'f', 'F', 't', 'T', ';', ',' }) do
    assert(vim.tbl_isempty(mapping(key)), key .. ' must retain its builtin meaning')
  end
  for _, key in ipairs({ 'grn', 'gra', 'grr', 'gri', 'grt', 'gO', '[d', ']d', '[b', ']b' }) do
    assert(mapping(key).desc and mapping(key).desc ~= '', key .. ' must retain its native mapping')
  end
  eq(mapping('an', 'x').desc, 'Select parent (outer) node')
  eq(mapping('in', 'x').desc, 'Select child (inner) node')
  eq(mapping('grd').desc, 'LSP definition')
  assert(mapping(' af', 'o').callback == nil) -- Space is not a text-object prefix.
  assert(mapping('af', 'o').callback)
  assert(mapping('if', 'x').callback)
  eq(vim.g.mapleader, ' ')
  assert(vim.o.wrap and vim.o.linebreak and vim.o.breakindent)
  eq(vim.o.showtabline, 2)
  -- Catch a second theme (e.g. Stylix) replacing the editor palette.
  eq(vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).bg, tonumber('303446', 16))
  eq(require('catppuccin').options.flavour, 'frappe')
  eq(require('catppuccin').options.transparent_background, false)
  local status = require('lualine').get_config()
  eq(status.options.theme, 'catppuccin-frappe')
  eq(status.options.icons_enabled, false)
  assert(require('bufferline'))
  eq(vim.diagnostic.config().virtual_lines.current_line, true)
  eq(require('mini.surround').config.mappings.add, 'ys')
  eq(require('mini.surround').config.mappings.delete, 'ds')
  assert(not package.loaded['nvim-autopairs'])
  assert(not package.loaded['mini.ai'])
  -- Autosave is disabled by default, including on focus loss.
  eq(vim.g.autosave_enabled, false)
  -- Debounced autosave runs through normal write hooks when explicitly enabled.
  local first = edit(temp .. '/first.txt', { 'before' })
  vim.api.nvim_buf_set_lines(first, 0, -1, false, { 'unsaved' })
  vim.api.nvim_exec_autocmds('FocusLost', {})
  eq(workflow.save(first), false)
  eq(vim.fn.readfile(temp .. '/first.txt'), { 'before' })
  vim.g.autosave_enabled = true
  vim.api.nvim_buf_set_lines(first, 0, -1, false, { 'after idle' })
  vim.api.nvim_exec_autocmds('TextChanged', { buffer = first })
  assert(vim.wait(4000, function() return not vim.bo[first].modified end), 'idle autosave did not run')
  eq(vim.fn.readfile(temp .. '/first.txt'), { 'after idle' })
  vim.api.nvim_buf_set_lines(first, 0, -1, false, { 'after focus loss' })
  vim.api.nvim_exec_autocmds('FocusLost', {})
  eq(vim.fn.readfile(temp .. '/first.txt'), { 'after focus loss' })
  vim.bo[first].readonly = true
  vim.api.nvim_buf_set_lines(first, 0, -1, false, { 'must not save' })
  eq(workflow.save(first), false)
  eq(vim.fn.readfile(temp .. '/first.txt'), { 'after focus loss' })
  vim.bo[first].readonly = false
  vim.b[first].autosave = false
  eq(workflow.save(first), false)
  vim.b[first].autosave = nil
  vim.g.autosave_enabled = false
  eq(workflow.save(first), false)
  vim.g.autosave_enabled = true
  vim.cmd.enew()
  local unnamed = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(unnamed, 0, -1, false, { 'unnamed' })
  eq(workflow.save(unnamed), false)
  vim.bo[unnamed].modified = false
  -- Operators compose with Tree-sitter text objects; native syntax selection stays available.
  local code = edit(temp .. '/project/subdir/example.lua', {
    'local function example(value)', '  return value + 1', 'end', '', 'example(1)',
  })
  vim.wait(200, function() return false end, 10)
  vim.api.nvim_win_set_cursor(0, { 2, 3 })
  vim.api.nvim_feedkeys('vaf', 'xt', false)
  assert(vim.fn.mode():match('[vV]'), 'function text object did not enter Visual mode')
  vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'xt', false)
  vim.cmd.lcd(vim.fn.fnameescape(temp .. '/project/subdir'))
  eq(workflow.project_root(), temp .. '/project')
  -- Exercise both picker entry points against the real Telescope plugin.
  vim.o.columns, vim.o.lines = 120, 40
  mapping(' f').callback()
  local prompt = vim.api.nvim_get_current_buf()
  eq(require('telescope.actions.state').get_current_picker(prompt).cwd, temp .. '/project/subdir')
  require('telescope.actions').close(prompt)
  mapping(' F').callback()
  prompt = vim.api.nvim_get_current_buf()
  eq(require('telescope.actions.state').get_current_picker(prompt).cwd, temp .. '/project')
  require('telescope.actions').close(prompt)
  -- Multiple-cursor maps add cursors without repurposing Vim's motion/editing keys.
  vim.api.nvim_buf_set_lines(code, 0, -1, false, { 'word word word' })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  mapping(' mn').callback()
  vim.wait(100, function() return false end, 10)
  assert(require('multicursor-nvim').hasCursors(), 'multiple-cursor mapping did not add a cursor')
  eq(workflow.save(code), false)
  mapping(' mx').callback()
  assert(not require('multicursor-nvim').hasCursors())
  -- CursorHold requests document highlights from an attached real stdio test server.
  local log = temp .. '/lsp.log'
  local id = vim.lsp.start({ name = 'workflow-test',
    cmd = { vim.fn.exepath('python3'), vim.env.PATH_LSP_TEST_SERVER },
    cmd_env = { PATH_LSP_LOG = log }, root_dir = temp,
  }, { bufnr = code })
  assert(vim.wait(5000, function() return vim.lsp.get_client_by_id(id).initialized end))
  vim.api.nvim_exec_autocmds('CursorHold', { buffer = code })
  assert(vim.wait(3000, function()
    return vim.fn.filereadable(log) == 1 and table.concat(vim.fn.readfile(log), '\n'):find('textDocument/documentHighlight', 1, true)
  end), 'document highlights were not requested')
  assert(package.loaded.lsp_signature, 'automatic signature help plugin not loaded')
  vim.lsp.stop_client(id, true)
  vim.fn.delete(temp, 'rf')
  print('nvim-workflow: integration tests passed')
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd.cquit()
else
  vim.cmd('qa!')
end
