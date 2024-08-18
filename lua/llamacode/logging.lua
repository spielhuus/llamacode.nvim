local M = {}

local logfile = io.open("log.txt", "w")
function M.write(name, text)
  if logfile then -- Check if the file opened successfully
          io.output(logfile)
          io.write(name, ": ", text, "\n")
          io.flush()
  else
    print("Error opening log file.") -- Handle potential error gracefully
  end
end

return M;
