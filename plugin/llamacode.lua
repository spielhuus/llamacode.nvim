-- require('llamacode')
--
--
--

-- local augroup = vim.api.nvim_create_augroup("Llamacode", { clear = true })
--
-- -- vim.api.nvim_create_autocmd("BufNew",
-- --         {
-- --                 group = augroup,
-- --                 desc = "new buffer created",
-- --                 once = false,
-- --                 callback = function(ev)
-- --                         print("check new buffer: " .. ev);
-- --                         -- if vim.bo[ev.buf].filetype == 'llm' then
-- --                         --         print(string.format('new event fired: %s', vim.inspect(ev)))
-- --                         -- end
-- --                 end
-- --         })
--
-- vim.api.nvim_create_autocmd({ "BufNew" }, {
--         pattern = 'llm',
--         callback = function(ev)
--         end
-- })
-- vim.api.nvim_create_autocmd({ "BufNewFile" }, {
--         callback = function(ev)
--                 print(string.format('new file event fired: %s', vim.inspect(ev) .. " filetype: '" .. vim.bo[ev.buf].filetype .. "'"))
--                 if vim.bo[ev.buf].filetype == 'llm' then
--                         print(string.format('new event fired: %s', vim.inspect(ev)))
--                 end
--         end
--         -- if type(markview.configuration.highlight_groups) == "table" then
--         -- 	markview.add_hls(markview.configuration.highlight_groups);
--         -- end
-- })
-- vim.api.nvim_create_autocmd({ "BufRead" }, {
--         callback = function(ev)
--                 print(string.format('event fired: %s', vim.inspect(ev) .. " filetype: '" .. vim.bo[ev.buf].filetype .. "'"))
--                 if vim.bo[ev.buf].filetype == 'llm' then
--                         print(string.format('new event fired: %s', vim.inspect(ev)))
--                 end
--         end
--         -- if type(markview.configuration.highlight_groups) == "table" then
--         -- 	markview.add_hls(markview.configuration.highlight_groups);
--         -- end
-- })
-- vim.api.nvim_create_autocmd({ "BufAdd" }, {
--         callback = function(ev)
--                 print(string.format('event fired: %s', vim.inspect(ev) .. " filetype: '" .. vim.bo[ev.buf].filetype .. "'"))
--                 if vim.bo[ev.buf].filetype == 'llm' then
--                         print(string.format('new event fired: %s', vim.inspect(ev)))
--                 end
--         end
--         -- if type(markview.configuration.highlight_groups) == "table" then
--         -- 	markview.add_hls(markview.configuration.highlight_groups);
--         -- end
-- })
-- vim.api.nvim_create_autocmd({ "BufModifiedSet" }, {
--         callback = function(ev)
--                 print(string.format('modified event fired: %s', vim.inspect(ev) .. " filetype: '" .. vim.bo[ev.buf].filetype .. "'"))
--                 if vim.bo[ev.buf].filetype == 'llm' then
--                         print(string.format('new event fired: %s', vim.inspect(ev)))
--                 end
--         end
--         -- if type(markview.configuration.highlight_groups) == "table" then
--         -- 	markview.add_hls(markview.configuration.highlight_groups);
--         -- end
-- })
-- -- vim.api.nvim_create_autocmd({ "BufNewFile" }, {
-- --         callback = function(ev)
-- --                 print(string.format('event fired: %s', vim.inspect(ev)))
-- --         end
-- --         -- if type(markview.configuration.highlight_groups) == "table" then
-- --         -- 	markview.add_hls(markview.configuration.highlight_groups);
-- --         -- end
-- -- })
-- -- vim.api.nvim_create_autocmd({ "BufRead" }, {
-- --         callback = function(ev)
-- --                 print(string.format('read event fired: %s', vim.inspect(ev)))
-- --         end
-- --         -- if type(markview.configuration.highlight_groups) == "table" then
-- --         -- 	markview.add_hls(markview.configuration.highlight_groups);
-- --         -- end
-- -- })
-- -- vim.api.nvim_create_autocmd({ "FileReadCmd" }, {
-- --         callback = function(ev)
-- --                 print(string.format('read event fired: %s', vim.inspect(ev)))
-- --         end
-- --         -- if type(markview.configuration.highlight_groups) == "table" then
-- --         -- 	markview.add_hls(markview.configuration.highlight_groups);
-- --         -- end
-- -- })
