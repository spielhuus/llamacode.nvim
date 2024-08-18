local trim_table = require("llamacode.utils").trim_table;
local buffer = require("llamacode.buffer");
local log = require("llamacode.logging");

--- Parse a prompt into a farmat suitable for the Ollama API.
-- This function constructs a table representing the prompt to be sent to the Ollama API,
-- including the template and any previous msages in the conversation history.
-- @param opts table: Options table containing the model name.
-- @param prompt table: Prompt table with a `template` field.
-- @param options table: Additional options for the API request.
-- @param history table: Table of previous messages in the conversation.
-- @return table: A table representing the formatted prompt, suitable for sending to the Ollama API.
local parse_prompt = function(_, content)
        local messages = {};
        table.insert(messages, {
                role = "system",
                content = table.concat(content.prompt.content or {}, "\n")
        });
        for _, v in pairs(content.chat) do
                table.insert(messages, {
                        role = v.role,
                        content = table.concat(v.message or {}, "\n")
                });
        end

         if type(next(content.options)) == "nil" then
                return {
                        model = content.model,
                        messages = messages,
                        stream = true,
                }
        else
                return {
                        model = content.model,
                        options = content.options,
                        messages = messages,
                        stream = true,
                }
        end
end

local M = {}

M.models = function(opts)
        local models = "";
        local status = 0;

        --- Execute cURL command in a new job.
        local cmd = "curl --silent --no-buffer --fail-with-body http://" ..
        opts.host .. ":" .. tostring(opts.port) .. "/api/tags"
        Job_id = vim.fn.jobstart(cmd, {
                -- Callback function to execute with stdout data.
                on_stdout = function(_, data, _)
                        models = models .. data[1];
                end,
                -- Callback function to execute with stderr data.
                on_stderr = function(_, data, _)
                        local clean_data = trim_table(data)
                        if #clean_data > 0 then
                                print("Err: " .. data)
                        end
                end,
                -- Callback function to execute when job exits.
                on_exit = function(_, b)
                        if b ~= 0 then
                                status = b
                        end
                end
        })

        vim.fn.jobwait({ Job_id }, -1);
        if status > 0 then
                vim.notify("Error: " .. vim.inspect(status) .. " " .. vim.inspect(models), vim.log.levels.ERROR);
                return nil;
        else
                return vim.json.decode(models)
        end
end

M.model_info = function(opts, name)
        local models = "";
        local status = 0;

        --- Execute cURL command in a new job.
        local cmd = "curl --silent --no-buffer --fail-with-body -X POST http://" .. opts.host ..
            ":" ..
            opts.port .. "/api/show -d " .. vim.fn.shellescape(vim.json.encode({ model = name, verbose = true })) .. ""

        Job_id = vim.fn.jobstart(cmd, {
                -- Callback function to execute with stdout data.
                on_stdout = function(_, data, _)
                        models = models .. data[1];
                end,
                -- Callback function to execute with stderr data.
                on_stderr = function(_, data, _)
                        local clean_data = trim_table(data)
                        if #clean_data > 0 then
                                print("Err: " .. vim.inspect(data))
                        end
                end,
                -- Callback function to execute when job exits.
                on_exit = function(_, b)
                        if b ~= 0 then
                                M.status = b
                        end
                end
        })

        vim.fn.jobwait({ Job_id }, -1);
        if status > 0 then
                vim.notify("Error: " .. vim.inspect(status) .. " " .. vim.inspect(models), vim.log.levels.ERROR);
                return nil;
        else
                return vim.json.decode(models)
        end
end

M.stop = function() -- TODO prompt is not used
        if Job_id ~= nil then
                vim.fn.jobstop(Job_id);
        end
end

M.chat = function(opts, content)
        local role = "";
        -- local message = "";

        local cmd = "curl --silent --no-buffer -X POST http://" ..
                opts.host ..
                ":" ..
                opts.port ..
                "/api/chat -d " ..
                vim.fn.shellescape(
                        vim.json.encode(parse_prompt(opts, content))
                )

        -- log.write("CURL", cmd);

        -- message = '';
        Job_id = vim.fn.jobstart(cmd, {
                on_stdout = function(_, data, _)
                        local clean_data = trim_table(data);
                        if #clean_data > 0 then
                                local enc_line = vim.json.decode(clean_data[1]);
                                if enc_line['done'] == false then
                                        local token_role = enc_line["message"]["role"];
                                        if token_role ~= role then
                                                buffer.append_lines({ "\n", "### Role: " .. token_role .. "\n" });
                                                role = token_role;
                                        end
                                        local token = enc_line["message"]["content"];
                                        buffer.append_lines({ token });
                                end
                        end
                end,
                on_stderr = function(_, data, _)
                        local clean_data = trim_table(data);
                        if #clean_data > 0 then
                                buffer.append_lines({ "Err: " .. data });
                        end
                end,
                on_exit = function(_, b)
                        if b ~= 0 then
                                buffer.append_lines({ "Exit: " .. b });
                        end
                end,
        })
end

return M
