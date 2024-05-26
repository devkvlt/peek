return function()
  local params = vim.lsp.util.make_position_params()
  local result = vim.lsp.buf_request_sync(0, 'textDocument/definition', params, 1000)

  if not result then
    return
  end

  local locations = result[1].result

  if not locations or vim.tbl_isempty(locations) then
    return
  end

  local uri = locations[1].uri or locations[1].targetUri
  local range = locations[1].range or locations[1].targetRange

  local bufnr = vim.uri_to_bufnr(uri)

  local win_opts = {
    width = 85,
    height = 15,
    relative = 'cursor',
    row = 1,
    col = 1,
    border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
    title = ' ' .. uri:gsub('file://', '') .. ' ',
    title_pos = 'center',
  }

  local winid = vim.api.nvim_open_win(bufnr, true, win_opts)
  vim.api.nvim_set_option_value('winhl', 'Normal:Normal,FloatBorder:WinSeparator', { win = winid })
  vim.api.nvim_win_set_cursor(winid, { range.start.line + 1, range.start.character }) -- Set the cursor position in the new window
  vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
  vim.opt_local.signcolumn = 'no'

  vim.keymap.set('n', 'q', function()
    local id = vim.fn.win_getid()

    if vim.api.nvim_win_get_config(id).relative ~= '' then
      vim.keymap.set('n', 'q', 'q', { buffer = 0 })
      vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
      vim.api.nvim_win_close(id, false)
    end
  end, { buffer = 0 })
end
