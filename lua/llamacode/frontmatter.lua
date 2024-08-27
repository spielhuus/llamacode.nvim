local M = {}

local TOKEN_ORDER = {"model", "name", "stream", "prompt", "context", "options", "tools"};

-- Helper function to trim whitespaces
local function trim(str)
                return str:match("^%s*(.-)%s*$") or ""
end

local function is_number(str)
        if str == nil then return false end
        local pattern = "^[-+]?([0-9]*%.?[0-9]+)$"
        return string.match(str, pattern) ~= nil
end

local function is_indent(indent, string)
        for i = 1, indent do
                if string:sub(i, i) ~= ' ' then
                        return false;
                end
        end
        return true;
end

local function is_array(t)
  return #t > 0 and next(t, #t) == nil
end

local function decode_text(lines, index, indent)
        local map = {}

        while index <= #lines do
                local line = lines[index];
                if is_indent(indent, line) then
                        table.insert(map, trim(line));
                else
                        break;
                end
                index = index + 1;
        end
        return index - 1, map;
end

local function decode_map(lines, index, indent)
        local map = {}
        while index <= #lines do
                local line = lines[index];
                if not is_indent(indent, line) then
                        return index - 1, map;
                elseif line:match("^(.-)-%s*$") then
                        index, submap = decode_map(lines, index + 1, indent + 1);
                        table.insert(map, submap);
                elseif line:match("^(.-):%s*$") then
                        local key = line:match("^(.-):%s*$")
                        local submap = {};
                        index, submap = decode_map(lines, index + 1, indent + 1);
                        map[trim(key)] = submap;
                elseif line:match("^(.-): |%s*$") then
                        local key = line:match("^(.-): |$")
                        local text = {};
                        index, text = decode_text(lines, index + 1, indent + 1);
                        map[trim(key)] = text;
                elseif line:match("^(.-):(.-)$") then
                        local key, value = line:match("^(.-):(.-)$")
                        if is_number(trim(value)) then
                                map[trim(key)] = tonumber(trim(value));
                        elseif trim(value)=='true' or trim(value)=='false' then
                                map[trim(key)] = trim(value)=='true';
                        else
                                map[trim(key)] = trim(value);
                        end
                else
                        print("no match: " .. line)
                end
                index = index + 1;
        end
        return index - 1, map;
end

-- encode frontmatter functions

-- function to handle key values. 
-- When the keu is '-', the value is a list item. add it as a yaml list
-- otherwise create the entry with a key value pair.
local function process_key(k)
        if k == '-' then
                return '-'
        else
                return k .. ':'
        end
end

local function get_source(source)
        local info = debug.getinfo(source);
        local filename = string.gsub(info.source, '^@', '');

        local lines_iterator, err = io.lines(filename)
            if not lines_iterator then
                error("Cannot open file: " .. filename .. ": " .. err)
            end

        local i = 1;
        local result = {};
        for line in lines_iterator do
            if i == info.linedefined then
                    local _, pos = string.find(line, "function")
                    if pos then
                        table.insert(result, string.sub(line, pos - 7));
                    else
                            print("funciton start not found|")
                    end
            elseif i == info.lastlinedefined then
                    local pos = string.find(line, "end")
                    if pos then
                        table.insert(result, string.sub(line, 1, pos + 2));
                    else
                            print("funciton end not found|")
                    end
            elseif i > info.linedefined and i < info.lastlinedefined then
                table.insert(result, line);
            end
            i = i + 1;
        end

        return(result);
end

local function encode_value(k, v, result, indent)
        if type(v) == "table" and is_array(v) then
                table.insert(result, string.rep(" ", indent) .. process_key(k));
                for _, nv in pairs(v) do
                        encode_value("-", nv, result, indent + 2);
                end
        elseif type(v) == "table" then
                table.insert(result, string.rep(" ", indent) .. process_key(k));
                for nk, nv in pairs(v) do
                        encode_value(nk, nv, result, indent + 2);
                end
        elseif type(v) == "string" then
                if string.find(v, "\n") then
                        table.insert(result, string.rep(" ", indent) .. process_key(k) .. " |");
                        for _, line in ipairs(vim.split(v, '\n')) do
                                table.insert(result, string.rep(" ", indent + 2) .. line)
                        end
                else
                        table.insert(result, string.rep(" ", indent) .. process_key(k) .. " " .. v)
                end
        elseif type(v) == "function" then
                local fn = get_source(v);
                if #fn > 1 then
                        table.insert(result, string.rep(" ", indent) .. process_key(k) .. " |");
                        for _, line in ipairs(fn) do
                                table.insert(result, string.rep(" ", indent + 2) .. line)
                        end
                else
                        table.insert(result, string.rep(" ", indent) .. process_key(k) .. " " .. fn)
                end
        elseif type(v) == "boolean" then
                if v then
                        table.insert(result, string.rep(" ", indent) .. process_key(k) .. " true");
                else 
                        table.insert(result, string.rep(" ", indent) .. process_key(k) .. " false");
                end
        else
                print("unknown element: " .. k .. " " .. vim.inspect(v) .. " " .. type(v))
                table.insert(result, string.rep(" ", indent) .. process_key(k) .. " " .. v);
        end
end


-- Encode lua table into a YAML-like data.
M.encode_frontmatter = function(tbl)
        local result = {}
        for _, name in ipairs(TOKEN_ORDER) do
                if tbl[name] then
                        encode_value(name, tbl[name], result, 0);
                end
        end
        -- encode_table(tbl, result, 0);
        return result;
end

-- Decodes YAML-like data into a Lua table.
M.decode_frontmatter = function(fm)
        local _, map = decode_map(fm, 1, 0);
        return map;
end

return M
