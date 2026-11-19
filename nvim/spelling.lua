local M = {}

local function actions(params)
  local buf = vim.uri_to_bufnr(params.textDocument.uri)
  if not vim.api.nvim_buf_is_loaded(buf) or not vim.wo.spell then return {} end
  local row = params.range.start.line
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ''
  -- This provider negotiates UTF-8: LSP columns are byte offsets.
  local col = params.range.start.character
  return vim.api.nvim_buf_call(buf, function()
    local offset = 0
    while offset < #line do
      local bad = vim.fn.spellbadword(line:sub(offset + 1))[1]
      if bad == '' then break end
      local first, last = line:find(bad, offset + 1, true)
      if not first then break end
      if col >= first - 1 and col < last then
        local result = {}
        for _, suggestion in ipairs(vim.fn.spellsuggest(bad, 10)) do
          result[#result + 1] = {
            title = 'Spelling: ' .. suggestion, kind = 'quickfix',
            edit = { changes = { [params.textDocument.uri] = { {
              range = { start = { line = row, character = first - 1 },
                ['end'] = { line = row, character = last } },
              newText = suggestion,
            } } } },
          }
        end
        return result
      end
      offset = last
    end
    return {}
  end)
end

function M.attach(buf)
  if vim.bo[buf].buftype ~= '' then return end
  vim.lsp.start({
    name = 'spelling',
    cmd = function(dispatchers)
      local closing, request_id = false, 0
      return {
        request = function(method, params, callback)
          local result
          if method == 'initialize' then
            result = { capabilities = { positionEncoding = 'utf-8',
              codeActionProvider = { codeActionKinds = { 'quickfix' } } } }
          elseif method == 'textDocument/codeAction' then
            result = actions(params)
          end
          callback(nil, result)
          request_id = request_id + 1
          return true, request_id
        end,
        notify = function(method)
          if method == 'exit' then
            closing = true
            dispatchers.on_exit(0, 0)
          end
          return true
        end,
        is_closing = function() return closing end,
        terminate = function() closing = true end,
      }
    end,
  }, { bufnr = buf })
end

return M
