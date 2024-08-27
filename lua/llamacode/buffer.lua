M = {}

local utils = require("llamacode.utils")
local fm = require("llamacode.frontmatter")

local start_win = 0;
local win = 0;
local buf = 0;

local get_win_opts = function ()

    local win_width = vim.api.nvim_win_get_width(0)
    local win_height = vim.api.nvim_win_get_height(0)
    local new_win_width = math.floor(win_width / 2)

    local result = {
        relative = 'win',
        width = new_win_width - 3,
        height = win_height - 3,
        row = 0,
        col = new_win_width,
        style = 'minimal',
        border = 'shadow',
    }

    return result
end

local set_mappings = function()
        vim.keymap.set("n", "<C-n>", "<cmd>Llama Chat<cr>", {
                nowait = true,
                noremap = true,
                silent = true,
                buffer = buf,
        })
        vim.keymap.set("n", "<C-c>", require("llamacode.ollama").stop, {
                nowait = true,
                noremap = true,
                silent = true,
                buffer = buf,
        })
        vim.keymap.set("n", "<C-r>", "<cmd>Llama Run<cr>", {
                nowait = true,
                noremap = true,
                silent = true,
                buffer = buf,
        })
end

--- Append a token to the end of the text.
-- 
-- Unlike appending a list of strings to a Neovim buffer where
-- each item starts on a new line by default, in this implementation,
-- the tokens do not automatically create new lines but the text
-- is appended to the last line. To create a
-- new line, you must manually add the '\n' character."
-- 
-- @param buf The buffer id.
-- @param tokens the token from the llm.
M.append_lines = function(tokens)
        -- this code is proudly copied from the 'Gen.nvim' plugin.
        -- --i cant to better >*-- 
        local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

        local last_row = #all_lines
        local last_row_content = all_lines[last_row]
        local last_col = string.len(last_row_content)
        local text = table.concat(tokens or {}, "\n")
        vim.api.nvim_buf_set_text(
                buf,
                last_row - 1,
                last_col,
                last_row - 1,
                last_col,
                vim.split(text, "\n")
        );

        -- Move the cursor to the end of the new lines
        vim.api.nvim_win_set_cursor(win, {last_row + #tokens - 1, 0})
end

M.new = function()

        -- warn when the window is already open
        if buf > 0 then
                vim.notify("Warning: Buffer " .. buf .. " already assigned", vim.log.levels.WARN);
        end

        -- creat the new buffer
        start_win = vim.api.nvim_get_current_win()
        buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_name(buf, "LLM Chat: #" .. buf)
        vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
        vim.api.nvim_set_option_value("filetype", "markdown", {buf = buf})

        -- creat the windown
        win = vim.api.nvim_open_win(buf, true, get_win_opts());
        vim.api.nvim_set_option_value("wrap", true, { win = win })
        vim.api.nvim_set_option_value("cursorline", true, { win = win })

        -- autogroup for treminating thre llm process when window closes
        local group = vim.api.nvim_create_augroup("llama", { clear = true })
        vim.api.nvim_create_autocmd("WinClosed", {
                buffer = buf,
                group = group,
                callback = function()
                        require("llamacode").opts.provider.stop() -- TODO can the outer opts be used
                        if buf then
                                vim.api.nvim_buf_delete(buf, { force = true })
                                buf = 0
                        end
                        require("llamacode").prompt = nil -- TODO can the outer opts be used
                end,
        })
        set_mappings();
end

M.set_content = function(opts, document)

        local last_row = 1;
        local content =
            vim.iter({ "---",
                        fm.encode_frontmatter(document),
                    "---", "",
            }):flatten():totable();

        vim.api.nvim_buf_set_lines(buf, last_row - 1, -1, false, content);
        last_row = last_row + #content;

        local context = {};
        if document.context then
                context = document.context(opts.source_buf, opts.line1, opts.line2);
        end

        -- add the history, when there is some
        if document.history then
                for _, v in pairs(document.history) do
                        local prompt = { "## Role: " .. v.role}
                        local messages = vim.split(utils.TemplateVars(context, v.content), '\n')
                        vim.api.nvim_buf_set_lines(buf, last_row - 1, -1, false, prompt);
                        vim.api.nvim_buf_set_lines(buf, last_row + #prompt - 1, -1, false, messages);
                        last_row = last_row + #prompt + #messages;
                end
        end
end

M.get_content = function(_)
        local document = { chat = {}};

        local context = "none";
        local values = {};

        local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        for i, value in ipairs(all_lines) do
                if value:match("^---$") then
                        if context == "front_matter" then
                                document = vim.tbl_deep_extend('force', document, fm.decode_frontmatter(values));
                                context = "none";
                                values = {};
                        elseif i == 1 then
                                context = "front_matter";
                        end
                elseif value:match("^## Role: (.*)$") then
                        local role = value:match("Role: (.*)");
                        if context ~= "none" then
                                table.insert(document.chat, { role=context, message=values})
                        end
                        context = role;
                        values = {};
                else
                        table.insert(values, value);
                end
        end

        if context ~= "none" then
                table.insert(document.chat, { role=context, message=values})
        end
        return document
end

--- Move the cursor to the last line.
M.jump_last = function()
  local total_lines = vim.api.nvim_buf_line_count(buf)
  if total_lines > 0 then
    vim.api.nvim_win_set_cursor(0, {total_lines, 0})
  end
end

return M
