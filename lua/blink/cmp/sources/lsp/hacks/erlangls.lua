-- [[
-- Example response from the erlang_ls lsp when typing module attributes
-- {
-- is_incomplete_backward = true,
-- is_incomplete_forward = false,
-- items = {{
--      client_id = 1,
--      client_name = "erlangls",
--      cursor_column = 1,
--      insertText = "behaviour(${1:Behaviour}).",
--      insertTextFormat = 2,
--      kind = 15,
--      label = "-behaviour()."
--      },
--      ...
--  }
--}

local erlang_ls = {}

--- @param response blink.cmp.CompletionResponse | nil
--- @return blink.cmp.CompletionResponse | nil
function erlang_ls.process_response(response)
  if not response then return response end

  local items = response.items
  if not items then return response end

  for _, item in ipairs(items) do
    -- % Some Erlang LS items (like - module) include a textEdit
    -- but blink.cmp ignores the '-' prefix because of it applies textEdit
    -- fix insertText for snippets (insertTextFormat=2)
    if item.insertTextFormat == 2 and item.label:match('^%-') then
      if not item.insertText:match('^%-') then item.insertText = '-' .. item.insertText end
    end

    local te = item.textEdit
    if te and te.newText and item.label:match('^%-') then
      -- ensure '-' prefix is preserved in the inserted text
      if not te.newText:match('^%-') then te.newText = '-' .. te.newText end
      -- Adjust the range start one char back if needed
      if te.range and te.range.start.character > 0 then te.range.start.character = te.range.start.character - 1 end
    end
  end

  return response
end

return erlang_ls
