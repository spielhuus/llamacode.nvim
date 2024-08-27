local M = {}

local buffer = require('llamacode.buffer')
local utils = require('llamacode.utils')

local selected_model = nil;
local selected_prompt = nil;

--- Create a document based on user options.
-- This function creates a document using the specified prompt or the default one.
-- @param opts table: Optional parameters for creating the document.
-- @return table: A table representing the created document.
local create_document = function(opts)
        local prompt = {};
        if selected_prompt then
                prompt = selected_prompt;
        elseif opts.default_prompt then
                prompt = M.opts.prompts[opts.default_prompt];
        else
                prompt = M.opts.prompts["default"];
        end

        if selected_model then
                prompt.model = selected_model;
        end
        -- TODO get selected model
        return prompt;
end

--- Loads prompts from a Lua file into the provided options table.
-- @param opts table: A table where prompts will be stored.
-- @param path string: The path to the Lua file containing the prompts.
-- @return void
local function load_prompt(opts, path)
        local file = dofile(path);
        for k,v in pairs(file) do
                opts.prompts[k] = v;
        end
end

-- document created from the settings.
M.document = {};

M.opts = {
        model = "llama3.1",
        host = '127.0.0.1',
        port = '11434',
        provider = require('llamacode.ollama'),
        picker = require('llamacode.telescope'),
        default_prompts = true,
        prompts = {}
}

--- Set up LlamaCode with custom options.
-- This function initializes LlamaCode by setting configuration
-- options and loading prompts from both the user's configuration
-- directory and project-specific directories.
-- @param opts table: A table containing the configuration options
--                    to be set for LlamaCode. Supported options include
--                    'default_prompts', which, when true, loads default
--                    prompts from a built-in module.
M.setup = function(opts)
        for k, v in pairs(opts) do M.opts[k] = v end
        if M.opts.default_prompts then
                M.opts.prompts = require("llamacode.prompts")
        end

        local config_dir = vim.env.HOME .. '/.config/llamacode'
        local project_dir = '.nvim/llamacode'

        for _, file in ipairs(vim.fn.glob(config_dir .. '/*.lua', true, true)) do
          load_prompt(M.opts, file);
        end

        for _, file in ipairs(vim.fn.glob(project_dir .. '/*.lua', true, true)) do
          load_prompt(M.opts, file);
        end
end

--- Create a new chat buffer and add the LLM setup.
M.new = function(opts)
        buffer.new();
        buffer.set_content(opts, create_document());
end

--- Add a message to the chat buffer
-- @param msg table? : A table containing the parts of the message to be displayed.
M.message = function(msg)
        local message = { "\n", "## Role: user", "\n" }
        if msg then
                for _, part in ipairs(msg) do
                        table.insert(message, part)
                end
        end
        buffer.append_lines(message)
        buffer.jump_last();
end

--- Execute the contents of the buffer using the LLM provider's API.
M.run = function(opts)
        local content = buffer.get_content(opts);
        -- print(vim.inspect(content));
        opts.provider.chat(opts, content);
        buffer.jump_last();
end

--- Select the LLM model.
M.models = function(opts, cb)
        local models = opts.provider.models(M.opts);
        if models then
                opts.picker.models({}, models.models, cb);
        end
end

--- Select the LLM prompt
M.prompts = function(opts, cb)
        opts.picker.prompts({}, opts.prompts, cb);
end

--- Register the user commands.
vim.api.nvim_create_user_command("Llama", function(arg)
        local mode
        if arg.range == 0 then
                mode = "n"
        else
                mode = "v"
        end
        arg.source_buf = vim.fn.winbufnr(0);
        if arg.args == "Prompt" then
                M.prompts(M.opts, function(item)
                        selected_prompt = M.opts.prompts[item.value];
                        M.new(vim.tbl_deep_extend('force', M.opts, arg));
                        if mode == 'v' then
                                M.message(utils.GetBlock(arg.source_buf,  arg.line1, arg.line2));
                        end
                end)
        elseif arg.args == "Model" then
                M.models(M.opts, function(item)
                        selected_model = item.model;
                end)
        elseif arg.args == "Run" then
                return M.run(M.opts);

        elseif arg.args == "Chat" then
                M.message();
        else
                print("Unknown command: " .. arg.args)
        end
end, {
        range = true,
        nargs = "?",
        complete = function()
                return { 'Prompt', 'Model', 'Run', 'Chat' }
        end
})

return M
