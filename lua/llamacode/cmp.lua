local cmp = require 'cmp'

local source = {}

source.new = function()
        local opts = require("llamacode").opts;
        local self = setmetatable({}, { __index = source })
        self.models = opts.provider.models(opts);
        return self
end

-- source.get_trigger_characters = function()
--   return { ':' }
-- end

-- source.is_available = function(self)
--   local filename = vim.fn.expand("%:p")
--   for _, glob in ipairs(_ELEKTRON_CFG.files) do
--     local re = vim.regex(glob)
--     local s, e = re:match_str(filename)
--     if s and e then
--       return true
--     end
--   end
--   return false
-- end
--
source.get_keyword_pattern = function(_, _)
  return "[a-zA-Z0-9_]+"
end

source.complete = function(self, params, callback)
  -- local before_line = params.context.cursor_before_line
  -- local items = {}
  --
  -- local re = vim.regex('Element("[a-zA-Z0-9]*", "')
  -- local s, e = re:match_str(before_line)
  -- if s and e then
  --   if (before_line:sub(- #':') == ':') then
  --     local index = before_line:match'^.*()"';
  --     local lib = string.sub(before_line, index+1, -2)
  --     if SYMBOL_LIBRARIES[lib] ~= nil then
  --
  --       local job = vim.fn.jobstart({ "elektron", "list", "--input", SYMBOL_LIBRARIES[lib] }, {
  --         stdout_buffered = true,
  --         on_stdout = function(_, data)
  --           if data then
  --             local tab = vim.fn.json_decode(data[1])
  --             for i, symbol in pairs(tab) do
  --               local item = {
  --                 label = symbol.library, --name,
  --                 filterText = symbol.library,
  --                 insertText = symbol.library,
  --                 detail = "Symbol",
  --                 kind = cmp.lsp.CompletionItemKind.Folder,
  --                 description = symbol.description,
  --                 data = {
  --                   path = v,
  --                 },
  --               }
  --               table.insert(items, item)
  --             end
  --           end
  --         end,
  --         on_stderr = function(_, data)
  --           if data then
  --             vim.notify(data, vim.log.levels.ERROR)
  --           end
  --         end,
  --       })
  --       vim.fn.jobwait({ job })
  --     end
  --   else
  --     for k, v in pairs(SYMBOL_LIBRARIES) do
  --       local item = {
  --         label = k, --name,
  --         filterText = k,
  --         insertText = k,
  --         detail = "Symbol",
  --         kind = cmp.lsp.CompletionItemKind.Folder,
  --         data = {
  --           path = v,
  --         },
  --       }
  --       table.insert(items, item)
  --     end
  --   end
  -- else
  -- end
  callback(self.models)
end

-- source.resolve = function(self, completion_item, callback)
--   local data = completion_item.data
--   if data.stat and data.stat.type == 'file' then
--     local ok, documentation = pcall(function()
--       return self:_get_documentation(data.path, constants.max_lines)
--     end)
--     if ok then
--       completion_item.documentation = documentation
--     end
--   end
--   callback(completion_item)
-- end
--

return source;
