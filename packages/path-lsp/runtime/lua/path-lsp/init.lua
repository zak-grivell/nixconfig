local M = {}
local options, base
local states, environments = {}, {}
local aliases = {
  bash = 'sh', javascript = 'javascript', jsx = 'javascriptreact', tsx = 'typescriptreact',
  ['c++'] = 'cpp', ['c-sharp'] = 'cs', ['f-sharp'] = 'fsharp', gitconfig = 'gitconfig',
  ['git-commit'] = 'gitcommit', ['git-rebase'] = 'gitrebase', markdown = 'markdown',
  ['protobuf'] = 'proto', ['dockerfile'] = 'dockerfile', ['nushell'] = 'nu',
  ['common-lisp'] = 'lisp', ['sshclientconfig'] = 'sshconfig', ['openssh'] = 'sshdconfig',
}

local function warn(message)
  vim.notify_once('path-lsp: ' .. message, vim.log.levels.WARN)
end

-- Maps are recursive; arrays replace, including empty arrays. Languages merge by name.
local function merge(a, b)
  local out = vim.deepcopy(a or {})
  for key, value in pairs(b or {}) do
    if key == 'language' then
      out.language = out.language or {}
      for _, language in ipairs(value) do
        local index
        for i, old in ipairs(out.language) do
          if old.name == language.name then index = i; break end
        end
        if index then out.language[index] = merge(out.language[index], language)
        else table.insert(out.language, vim.deepcopy(language)) end
      end
    elseif type(value) == 'table' and not vim.islist(value) then
      out[key] = merge(type(out[key]) == 'table' and out[key] or {}, value)
    else
      out[key] = vim.deepcopy(value)
    end
  end
  return out
end

local function read_json(path)
  return vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
end

local function validate(config)
  assert(type(config) == 'table', 'expected a TOML table')
  assert(not config.language or (type(config.language) == 'table' and vim.islist(config.language)), 'language must be a list')
  for _, language in ipairs(config.language or {}) do
    assert(type(language.name) == 'string', 'each language needs a name')
    for _, key in ipairs({ 'file-types', 'roots', 'language-servers', 'shebangs' }) do
      assert(language[key] == nil or (type(language[key]) == 'table' and vim.islist(language[key])), key .. ' must be a list')
    end
    if language.indent then
      assert(type(language.indent) == 'table', 'indent must be a table')
      assert(not language.indent.unit or type(language.indent.unit) == 'string', 'indent.unit must be a string')
      local width = language.indent['tab-width']
      assert(not width or (type(width) == 'number' and width > 0), 'tab-width must be positive')
    end
    if language.formatter then
      local formatter_spec = language.formatter
      assert(type(formatter_spec) == 'table' and type(formatter_spec.command) == 'string', 'formatter needs a command')
      if formatter_spec.args then
        assert(type(formatter_spec.args) == 'table' and vim.islist(formatter_spec.args), 'formatter args must be a list')
        for _, arg in ipairs(formatter_spec.args) do assert(type(arg) == 'string', 'formatter arguments must be strings') end
      end
    end
  end
  for _, server in pairs(config['language-server'] or {}) do
    assert(type(server) == 'table', 'server must be a table')
    assert(not server.command or type(server.command) == 'string', 'server command must be a string')
    if server.args then
      assert(type(server.args) == 'table' and vim.islist(server.args), 'server args must be a list')
      for _, arg in ipairs(server.args) do assert(type(arg) == 'string', 'server arguments must be strings') end
    end
  end
  return config
end

local function project_for(path)
  local marker = vim.fs.find({ '.git' }, { path = vim.fs.dirname(path), upward = true })[1]
  return marker and vim.fs.dirname(marker) or vim.fs.dirname(path)
end

local function environment(directory)
  if environments[directory] then return environments[directory] end
  local env = vim.fn.environ()
  local marker = vim.fs.find({ '.envrc', '.env' }, { path = directory, upward = true })[1]
  if marker then
    if vim.fn.executable('direnv') ~= 1 then return nil, 'direnv is required for ' .. marker end
    local result = vim.system({ 'direnv', 'exec', directory, 'env', '-0' }, { text = false }):wait()
    if result.code ~= 0 then return nil, 'direnv could not load ' .. directory .. ': ' .. (result.stderr or '') end
    env = {}
    for entry in result.stdout:gmatch('([^%z]+)') do
      local key, value = entry:match('^([^=]+)=(.*)$')
      if key then env[key] = value end
    end
  end
  environments[directory] = env
  return env
end

local function executable(command, env, directory)
  if not command or command == '' then return nil end
  if command:find('/', 1, true) then
    local path = command:sub(1, 1) == '/' and command or directory .. '/' .. command
    return vim.fn.executable(path) == 1 and path or nil
  end
  for part in ((env.PATH or '') .. ':'):gmatch('(.-):') do
    if part == '' then part = directory elseif part:sub(1, 1) ~= '/' then part = directory .. '/' .. part end
    local path = part .. '/' .. command
    if vim.fn.executable(path) == 1 then return path end
  end
end

local function filetype(language)
  return aliases[language.name] or language.name
end

local function matches(language, path, bufnr)
  -- File patterns take precedence over Neovim's built-in filetype mapping.
  local best = 0
  for _, pattern in ipairs(language['file-types'] or {}) do
    if type(pattern) == 'string' then
      if path:sub(-#pattern - 1) == '.' .. pattern then best = math.max(best, #pattern + 1) end
    elseif pattern.glob then
      local regex = vim.fn.glob2regpat(pattern.glob)
      if vim.fn.match(path, regex) >= 0 or vim.fn.match(vim.fs.basename(path), regex) >= 0 then
        best = math.max(best, 1000 + #pattern.glob)
      end
    end
  end
  if best == 0 and vim.bo[bufnr].filetype == filetype(language) then best = 1 end
  if best == 0 then
    local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
    if first:sub(1, 2) == '#!' then
      for _, interpreter in ipairs(language.shebangs or {}) do
        if first:match('%f[%w]' .. vim.pesc(interpreter) .. '%f[%W]') then best = 1; break end
      end
    end
  end
  return best
end

local function language_for(config, path, bufnr)
  local selected, score = nil, 0
  for _, language in ipairs(config.language or {}) do
    local rank = matches(language, path, bufnr)
    if rank > score then selected, score = language, rank end
  end
  return selected
end

local function root_for(language, path, fallback)
  local roots = language.roots or {}
  if #roots > 0 then
    local marker = vim.fs.find(roots, { path = vim.fs.dirname(path), upward = true })[1]
    if marker then return vim.fs.dirname(marker) end
  end
  return fallback
end

local feature_methods = {
  ['format'] = 'textDocument/formatting', ['goto-definition'] = 'textDocument/definition',
  ['goto-declaration'] = 'textDocument/declaration', ['goto-type-definition'] = 'textDocument/typeDefinition',
  ['goto-reference'] = 'textDocument/references', ['goto-implementation'] = 'textDocument/implementation',
  ['hover'] = 'textDocument/hover', ['signature-help'] = 'textDocument/signatureHelp',
  ['completion'] = 'textDocument/completion', ['code-action'] = 'textDocument/codeAction',
  ['rename-symbol'] = 'textDocument/rename', ['document-symbols'] = 'textDocument/documentSymbol',
  ['workspace-symbols'] = 'workspace/symbol', ['inlay-hints'] = 'textDocument/inlayHint',
  ['document-highlight'] = 'textDocument/documentHighlight',
}

local function detach_stale(bufnr, keep)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name:match('^path%-lsp/') and not keep[client.id] then
      vim.lsp.buf_detach_client(bufnr, client.id)
      if next(client.attached_buffers) == nil then client:stop() end
    end
  end
end

local function start_servers(state, bufnr)
  state.servers = {}
  local keep = {}
  for _, entry in ipairs(state.language['language-servers'] or {}) do
    local name = type(entry) == 'string' and entry or entry.name
    local spec = (state.config['language-server'] or {})[name]
    if spec then
      local env = vim.tbl_extend('force', state.env, spec.environment or {})
      local command = executable(spec.command, env, state.directory)
      local allowed = true
      if spec['required-root-patterns'] then
        allowed = false
        for _, pattern in ipairs(spec['required-root-patterns']) do
          if #vim.fn.globpath(state.root, pattern, false, true) > 0 then allowed = true end
        end
      end
      table.insert(state.servers, { name = name, command = command or spec.command, available = command ~= nil, root_allowed = allowed })
      if command and allowed then
        local cmd = { command }
        vim.list_extend(cmd, spec.args or {})
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok, cmp = pcall(require, 'cmp_nvim_lsp')
        if ok then capabilities = cmp.default_capabilities(capabilities) end
        local only = type(entry) == 'table' and entry['only-features'] or nil
        local except = type(entry) == 'table' and entry['except-features'] or {}
        local disabled = {}
        for feature, method in pairs(feature_methods) do
          if (only and not vim.tbl_contains(only, feature)) or vim.tbl_contains(except, feature) then disabled[method] = true end
        end
        -- An empty Lua table encodes as [], but LSP configuration is an object.
        local settings = spec.config or vim.empty_dict()
        local signature = vim.fn.sha256(vim.inspect({ cmd, env, settings, entry }))
        local handlers = {}
        if (only and not vim.tbl_contains(only, 'diagnostics')) or vim.tbl_contains(except, 'diagnostics') then
          handlers['textDocument/publishDiagnostics'] = function() end
          disabled['textDocument/diagnostic'] = true
        end
        local id = vim.lsp.start({
          name = 'path-lsp/' .. name,
          cmd = cmd, cmd_env = env, cmd_cwd = state.directory, root_dir = state.root,
          capabilities = capabilities, init_options = settings, settings = settings,
          exit_timeout = 1000, handlers = handlers,
          _path_lsp_signature = signature,
          get_language_id = function(buffer, ft)
            local current = states[buffer]
            return current and (current.language['language-id'] or current.language.name) or ft
          end,
          on_init = function(client)
            client._path_lsp_signature = signature
            local supports = client.supports_method
            client.supports_method = function(self, method, ...)
              if disabled[method] then return false end
              return supports(self, method, ...)
            end
          end,
        }, {
          bufnr = bufnr,
          reuse_client = function(client, config)
            return client.name == config.name and client.root_dir == config.root_dir
              and client.config._path_lsp_signature == signature
          end,
        })
        if id then keep[id] = true end
      end
    else warn('unknown language server: ' .. tostring(name)) end
  end
  detach_stale(bufnr, keep)
end

local function formatter(state, bufnr)
  local spec = state.language.formatter
  if not spec then return end
  local command = executable(spec.command, state.env, state.directory)
  state.formatter = { command = command or spec.command, available = command ~= nil }
  if not command then return end
  local conform = require('conform')
  local name = 'path_lsp_' .. bufnr
  conform.formatters[name] = {
    command = command, stdin = true, env = state.env,
    cwd = function() return state.root end,
    args = function(_, ctx)
      local args = {}
      for _, arg in ipairs(spec.args or {}) do
        table.insert(args, (arg:gsub('%%{buffer_name}', function() return ctx.filename end)))
      end
      return args
    end,
  }
  state.formatter_name = name
end

function M.attach(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= '' then return end
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end
  local project = project_for(path)
  local config = base
  local language = language_for(config, path, bufnr)
  if not language then states[bufnr] = nil; detach_stale(bufnr, {}); return end
  local directory = vim.fs.dirname(path)
  local env, err = environment(directory)
  local state = { config = config, language = language, project = project,
    directory = directory, root = root_for(language, path, project), env = env, error = err }
  states[bufnr] = state
  if not env then detach_stale(bufnr, {}); warn(err); return end
  if vim.bo[bufnr].filetype == '' then vim.bo[bufnr].filetype = filetype(language) end
  if language.indent then
    local indent = language.indent
    vim.bo[bufnr].tabstop = indent['tab-width'] or 4
    vim.bo[bufnr].shiftwidth = indent.unit and #indent.unit or vim.bo[bufnr].tabstop
    vim.bo[bufnr].expandtab = indent.unit ~= '\t'
    if not vim.bo[bufnr].expandtab then vim.bo[bufnr].shiftwidth = vim.bo[bufnr].tabstop end
  end
  -- Grammar selection uses installed Neovim parsers, never downloads project code.
  local grammar = language.grammar or language.name
  local parser_aliases = { jsx = 'javascript', ['c++'] = 'cpp', bash = 'bash', ['c-sharp'] = 'c_sharp', ['common-lisp'] = 'commonlisp' }
  grammar = parser_aliases[grammar] or grammar:gsub('-', '_')
  state.grammar = grammar
  local ok = pcall(vim.treesitter.start, bufnr, grammar)
  state.grammar_available = ok
  start_servers(state, bufnr)
  formatter(state, bufnr)
end

function M.format_options(bufnr, on_save)
  local state = states[bufnr]
  if not state or state.error or (on_save and state.language['auto-format'] == false) then return nil end
  return { bufnr = bufnr, timeout_ms = 1500, lsp_format = 'fallback',
    formatters = state.formatter_name and { state.formatter_name } or {} }
end

function M.health(bufnr)
  return vim.deepcopy(states[bufnr or vim.api.nvim_get_current_buf()])
end

function M.reload()
  environments = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.attach(bufnr)
    end
  end
end

function M.setup(opts)
  options = opts or {}
  local source = debug.getinfo(1, 'S').source:sub(2)
  local package_root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(source)))
  local data = read_json(options.data or package_root .. '/languages.json')
  base = validate(merge(data.defaults, data.overrides))
  local conform = require('conform')
  conform.setup({ format_on_save = function(bufnr) return M.format_options(bufnr, true) end })
  local group = vim.api.nvim_create_augroup('path-lsp', { clear = true })
  vim.api.nvim_create_autocmd({ 'FileType', 'BufReadPost', 'BufNewFile' }, {
    group = group, callback = function(event)
      vim.schedule(function() if vim.api.nvim_buf_is_valid(event.buf) then M.attach(event.buf) end end)
    end,
  })
  vim.api.nvim_create_autocmd('BufWipeout', { group = group, callback = function(event)
    states[event.buf] = nil
    conform.formatters['path_lsp_' .. event.buf] = nil
  end })
  vim.api.nvim_create_user_command('PathLspReload', M.reload, {})
  vim.api.nvim_create_user_command('PathLspHealth', function()
    local state = M.health()
    if not state then vim.notify('path-lsp: no matching language'); return end
    vim.notify(vim.inspect({ language = state.language.name, root = state.root,
      servers = state.servers,
      formatter = state.formatter, grammar = state.grammar,
      grammar_available = state.grammar_available, error = state.error }))
  end, {})
  vim.api.nvim_create_user_command('PathLspFormat', function()
    local opts_for_buffer = M.format_options(vim.api.nvim_get_current_buf(), false)
    if opts_for_buffer then conform.format(opts_for_buffer) end
  end, {})
  vim.schedule(function() M.attach() end)
end

M._merge = merge
M._validate = validate
M._language_for = language_for
M._executable = executable
return M
