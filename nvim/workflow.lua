local M = {}
local timers = {}

local function cancel(buf)
  local timer = timers[buf]
  timers[buf] = nil
  if timer and not timer:is_closing() then timer:stop(); timer:close() end
end

function M.save(buf)
  if vim.g.autosave_enabled == false or not vim.api.nvim_buf_is_valid(buf)
      or not vim.api.nvim_buf_is_loaded(buf) then return false end
  local bo = vim.bo[buf]
  if vim.b[buf].autosave == false or not bo.modified or not bo.modifiable
      or bo.readonly or bo.buftype ~= '' or vim.api.nvim_buf_get_name(buf) == '' then return false end
  local mc = require('multicursor-nvim')
  if mc.hasCursors() or vim.fn.pumvisible() == 1 or vim.snippet.active() then return false end
  -- Do not use :write!: external changes and write errors must remain visible.
  local ok, err = pcall(vim.api.nvim_buf_call, buf, function() vim.cmd('silent update') end)
  if not ok then vim.notify_once('Autosave: ' .. tostring(err), vim.log.levels.WARN) end
  return ok
end

function M.project_root()
  local buf = vim.api.nvim_get_current_buf()
  local state = require('path-lsp').health(buf)
  if state then return state.root end
  local path = vim.api.nvim_buf_get_name(buf)
  local directory = path ~= '' and vim.fs.dirname(path) or vim.fn.getcwd()
  return vim.fs.root(directory, { '.git', 'flake.nix', 'package.json', 'Cargo.toml', 'pyproject.toml' }) or directory
end

local function pick(name, project)
  return function()
    local cwd = project and M.project_root() or vim.fn.getcwd()
    require('telescope.builtin')[name]({ cwd = cwd, hidden = false })
  end
end

function M.setup(opts)
  opts = opts or {}
  vim.g.autosave_enabled = false
  local group = vim.api.nvim_create_augroup('editor-workflow', { clear = true })
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    callback = function(event)
      cancel(event.buf)
      timers[event.buf] = vim.defer_fn(function()
        timers[event.buf] = nil
        M.save(event.buf)
      end, opts.autosave_delay or 1500)
    end,
  })
  vim.api.nvim_create_autocmd('FocusLost', { group = group, callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do cancel(buf); M.save(buf) end
  end })
  vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufWritePost' }, {
    group = group, callback = function(event) cancel(event.buf) end,
  })
  vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = function()
    for buf in pairs(timers) do cancel(buf) end
  end })

  vim.diagnostic.config({
    severity_sort = true, underline = true, signs = true, update_in_insert = false,
    virtual_text = { spacing = 2, severity = { min = vim.diagnostic.severity.WARN } },
    virtual_lines = { current_line = true },
    float = { border = 'rounded', source = 'if_many' },
  })
  -- Native [d, ]d and CTRL-W d remain the diagnostic navigation/float keys.
  vim.api.nvim_create_autocmd('CursorHold', { group = group, callback = function(event)
    if #vim.lsp.get_clients({ bufnr = event.buf, method = 'textDocument/documentHighlight' }) > 0 then
      vim.lsp.buf.document_highlight()
    end
  end })
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
    group = group, callback = function() vim.lsp.buf.clear_references() end,
  })

  require('nvim-treesitter-textobjects').setup({ select = { lookahead = true } })
  local map = function(mode, key, action, description)
    vim.keymap.set(mode, key, action, { silent = true, desc = description })
  end
  -- Neovim 0.12 already provides an/in (grow/shrink) and [n/]n (siblings).
  -- Add objects that compose with native d/c/y/v operators, without replacing them.
  for key, capture in pairs({ af = '@function.outer', ['if'] = '@function.inner',
      ac = '@class.outer', ic = '@class.inner', aa = '@parameter.outer', ia = '@parameter.inner' }) do
    map({ 'x', 'o' }, key, function()
      require('nvim-treesitter-textobjects.select').select_textobject(capture, 'textobjects')
    end, 'Select ' .. capture)
  end
  map('n', 'grd', vim.lsp.buf.definition, 'LSP definition')
  -- Do not map gr itself: native gra/grn/grr/gri/grt need that prefix.
  map('n', '<leader>f', pick('find_files', false), 'Find files (cwd)')
  map('n', '<leader>F', pick('find_files', true), 'Find files (project)')
  map('n', '<leader>g', pick('live_grep', true), 'Grep project')
  map('n', '<leader>G', pick('live_grep', false), 'Grep cwd')
  map('n', '<leader>b', pick('buffers', true), 'Buffers')
  map('n', '<leader>e', '<cmd>Oil<CR>', 'File explorer')
  map('n', '<leader>s', pick('lsp_document_symbols', true), 'Document symbols')
  map('n', '<leader>S', pick('lsp_dynamic_workspace_symbols', true), 'Workspace symbols')
  map('n', '<leader>d', '<cmd>Trouble diagnostics toggle<CR>', 'Diagnostics panel')
  map('n', '<leader>D', pick('diagnostics', true), 'Find diagnostics')
  map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
  map('n', '<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
  map('n', '<leader>cf', '<cmd>PathLspFormat<CR>', 'Format buffer')
  map('n', '<leader>ck', vim.lsp.buf.signature_help, 'Signature help')
  map('n', '<leader>ch', '<cmd>PathLspHealth<CR>', 'Language health')
  map('n', '<leader>cR', '<cmd>PathLspReload<CR>', 'Reload language tools')
  map('n', '<leader>j', function() require('flash').jump() end, 'Jump to text')
  map('n', '<leader>ua', function()
    vim.g.autosave_enabled = not vim.g.autosave_enabled
    vim.notify('Autosave ' .. (vim.g.autosave_enabled and 'enabled' or 'disabled'))
  end, 'Toggle autosave')
  map('n', '<leader>uw', function() vim.wo.wrap = not vim.wo.wrap end, 'Toggle soft wrap')
  map('n', '<leader>uh', function()
    local buf = vim.api.nvim_get_current_buf()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
  end, 'Toggle inlay hints')
  map('n', '<leader>ud', function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
  end, 'Toggle diagnostics')

  local mc = require('multicursor-nvim')
  map({ 'n', 'x' }, '<leader>mn', function() mc.matchAddCursor(1) end, 'Add next match')
  map({ 'n', 'x' }, '<leader>mN', function() mc.matchAddCursor(-1) end, 'Add previous match')
  map({ 'n', 'x' }, '<leader>ms', function() mc.matchSkipCursor(1) end, 'Skip next match')
  map({ 'n', 'x' }, '<leader>mS', function() mc.matchSkipCursor(-1) end, 'Skip previous match')
  map({ 'n', 'x' }, '<leader>ma', mc.matchAllAddCursors, 'Add all matches')
  map({ 'n', 'x' }, '<leader>mj', function() mc.lineAddCursor(1) end, 'Add cursor below')
  map({ 'n', 'x' }, '<leader>mk', function() mc.lineAddCursor(-1) end, 'Add cursor above')
  map({ 'n', 'x' }, '<leader>mJ', function() mc.lineSkipCursor(1) end, 'Skip line below')
  map({ 'n', 'x' }, '<leader>mK', function() mc.lineSkipCursor(-1) end, 'Skip line above')
  map({ 'n', 'x' }, '<leader>mt', mc.toggleCursor, 'Toggle cursors')
  map({ 'n', 'x' }, '<leader>mx', mc.clearCursors, 'Clear extra cursors')
  map('n', '<leader>mr', mc.restoreCursors, 'Restore cursors')
  map('x', '<leader>m/', mc.splitCursors, 'Split selection by regex')
  map('x', '<leader>mm', mc.matchCursors, 'Match within selection')
  -- Only active during multiple-cursor editing; ordinary Escape remains untouched.
  mc.addKeymapLayer(function(set)
    set('n', '<Esc>', function()
      if not mc.cursorsEnabled() then mc.enableCursors() else mc.clearCursors() end
    end)
    set({ 'n', 'x' }, '<leader>m[', mc.prevCursor)
    set({ 'n', 'x' }, '<leader>m]', mc.nextCursor)
  end)
  require('which-key').add({
    { '<leader>c', group = 'Code' }, { '<leader>u', group = 'Toggles' },
    { '<leader>m', group = 'Multiple cursors', mode = { 'n', 'x' } },
  })
  map('n', '<leader>?', function() require('which-key').show({ keys = '<Space>', loop = false }) end, 'Show Space menu')
end

return M
