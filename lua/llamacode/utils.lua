M = {}

local ts_utils = require 'nvim-treesitter.ts_utils'

--- Retrieve LSP nodes for a given buffer.
-- This function requests the document symbols (full syntax tree) from all LSP clients attached to the buffer.
-- @param bufnr number: Buffer number to retrieve LSP nodes for.
-- @return table or (nil, string): A table representing the LSP nodes, or nil followed by an error message.
M.trim_table = function(tbl)
        local function is_whitespace(str) return str:match("^%s*$") ~= nil end

        while #tbl > 0 and (tbl[1] == "" or is_whitespace(tbl[1])) do
                table.remove(tbl, 1)
        end

        while #tbl > 0 and (tbl[#tbl] == "" or is_whitespace(tbl[#tbl])) do
                table.remove(tbl, #tbl)
        end

        return tbl
end

local function lsp_nodes(bufnr)
        -- Ensure the buffer is valid
        if not vim.api.nvim_buf_is_valid(bufnr) then
                return nil, "Invalid buffer"
        end

        -- Get the LSP clients attached to the buffer
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        if #clients == 0 then
                return nil, "No active LSP clients for buffer"
        end

        -- Request the document symbols (full syntax tree)
        local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
        local result = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params)

        if not result or vim.tbl_isempty(result) then
                return nil, "No symbols found"
        end

        return result;
end

-- Retrieve the entire buffer
--- @return table table with the code lines.
M.GetBuffer = function(buf)
        local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local message = vim.iter({
                "```" .. vim.api.nvim_buf_get_option(buf, 'filetype'), current_lines, "```\n"
        }):flatten():totable();
        return message
end

--- Get the code block at a specific line in a buffer.
--- This function will get the lsp nodes for the given buffer,
--- and then search through the symbols to find a code block that includes the specified line.
--- If a code block is found, it will return a table containing the code block in markdown format.
--- Otherwise, it will return nil followed by an error message.
--- @param buf integer: The buffer ID.
--- @param line integer: The line number to search for a code block.
--- @return table|nil: A table representing the code block in markdown format,
--- @return nil|string: or nil followed by an error message if no code block was found.
M.GetCodeBlock = function(buf, line)
        local result = lsp_nodes(buf);
        if not result then
                return nil, "no lsp nodes found for buffer"
        end
        for _, client_result in pairs(result) do
                local symbols = client_result.result
                for k, v in pairs(symbols) do
                        local line_start = v['range']['start']['line'];
                        local line_end = v['range']['end']['line'] + 1;
                        if line >= line_start and line <= line_end then
                                local lines = vim.api.nvim_buf_get_lines(buf, line_start, line_end, false);
                                local message = vim.iter({
                                        "```" .. vim.api.nvim_buf_get_option(buf, 'filetype'), lines, "```\n"
                                }):flatten():totable();
                                return message;
                        end
                end
        end
        return nil, "no code found"
end

M.GetBlock = function(buf_nr, start, last)
        local current_lines = vim.api.nvim_buf_get_lines(
                buf_nr,
                start - 1,
                last,
                false);

        local message = vim.iter({
                "```" .. vim.api.nvim_buf_get_option(buf_nr, 'filetype'), current_lines, "```\n"
        }):flatten():totable();
        return message
end

M.JsonBlock = function(text)
        local json = vim.fn.json_encode(text);
        local command = "jq -n " .. vim.fn.shellescape(json);
        local result = vim.fn.system(command)
        local message = vim.iter({
                "```json", result, "```"
        }):flatten():totable();
        return message
end

---This method takes a string as a template.
--All placeholders `{VAR}` will be replaced with 
--the corresponding values from the dictionary. 
M.TemplateVars = function(dict, text)
        -- Use a pattern to find all occurrences of {VAR} in the text
        local res = (string.gsub(text, '{(%w+)}', function(var)
                -- Replace each occurrence with the corresponding value from the dictionary
                return table.concat(dict[var] or var, "\n")
        end))
        return res
end


M.GetLspDiagnostics = function(bufnr, lnum)
        -- Clear any previous diagnostics
        -- vim.diagnostic.reset(bufnr)

        -- Get the list of diagnostic messages at the specified line number
        local diagnostics = vim.diagnostic.get(bufnr)
        if not diagnostics then
                return {}
        end

        -- Filter diagnostics by line number
        local filtered_diagnostics = {}
        for _, diag in ipairs(diagnostics) do
                -- if diag.lnum == lnum then
                table.insert(filtered_diagnostics, diag)
                -- end
        end

        return filtered_diagnostics
end

return M
