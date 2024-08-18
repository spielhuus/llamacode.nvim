local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewers = require "telescope.previewers"

M = {}

-- M.models: Creates a picker for the LLM models.
--
-- @param opts Table Optional configuration options. See :ref:`conf`.
-- @param models Array of model entries to pick from.

function M.models(opts, models, cb)
    -- Set default value for opts if it's nil.
    opts = opts or {}

    -- Create a new picker with the given options and callback function.
    pickers.new(opts, {
        -- The title of the prompt.
        prompt_title = "LLM Models",

        -- Define the finder for this picker. A finder is responsible for
        -- generating a list of entries to display in the prompt.
        finder = finders.new_table({
            -- The results to display in the finder.
            results = models,

            -- Function to create an entry from a model table.
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry['name'],
                    ordinal = entry['name']
                }
            end
        }),

        -- Sorter for the picker. This determines how the entries are sorted.
        sorter = conf.generic_sorter(opts),

        -- Attach mappings to the picker. This function is called whenever a
        -- key is pressed in the prompt.
        attach_mappings = function(prompt_bufnr, map)
            -- Define a function to run when the default entry is selected.
            actions.select_default:replace(function()
                -- Close the prompt and print the selected entry to the console.
                actions.close(prompt_bufnr)

                -- Get the selected entry from the action state.
                local selection = action_state.get_selected_entry()
                --require('llamacode').opts['model'] = selection['display'];
                cb(selection.value);
            end)
            return true
        end,

        -- Previewer for the picker. This function is called when an entry is previewed.
        previewer = previewers.new_buffer_previewer({
            title = "Model Details",

            -- Define how to display the entry in a buffer preview.
            define_preview = function(self, entry, status)
                -- Set the lines of the buffer preview from the string representation
                -- of the entry.
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false,
                    vim.split(vim.inspect(entry), '\n'))
            end
        })
    }):find()
end

function M.prompts(opts, prompts, cb)
    -- Set default value for opts if it's nil.
    opts = opts or {}
         local prompt_names = {}
        for key, _ in pairs(prompts) do
            table.insert(prompt_names, key)
        end
        table.sort(prompt_names)

    -- Create a new picker with the given options and callback function.
    pickers.new(opts, {
        -- The title of the prompt.
        prompt_title = "LLM Prompts",

        -- Define the finder for this picker. A finder is responsible for
        -- generating a list of entries to display in the prompt.
        finder = finders.new_table({
            -- The results to display in the finder.
            results = prompt_names,

            -- Function to create an entry from a model table.
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry,
                    ordinal = entry,
                }
            end
        }),

        -- Sorter for the picker. This determines how the entries are sorted.
        sorter = conf.generic_sorter(opts),

        -- Attach mappings to the picker. This function is called whenever a
        -- key is pressed in the prompt.
        attach_mappings = function(prompt_bufnr, map)
            -- Define a function to run when the default entry is selected.
            actions.select_default:replace(function()
                -- Close the prompt and print the selected entry to the console.
                actions.close(prompt_bufnr)
                -- Get the selected entry from the action state.
                local selection = action_state.get_selected_entry()
                cb(selection);
            end)
            return true
        end,

        -- Previewer for the picker. This function is called when an entry is previewed.
        previewer = previewers.new_buffer_previewer({
            title = "Prompt Details",

            -- Define how to display the entry in a buffer preview.
            define_preview = function(self, entry, status)
                -- Set the lines of the buffer preview from the string representation
                -- of the entry.
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false,
                    vim.split(vim.inspect(entry), '\n'))
            end
        })
    }):find()
end
return M
