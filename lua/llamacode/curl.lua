local trim_table = require("llamacode.utils").trim_table

local M = {}

M.status = 0;

--- Execute a GET request using cURL.
-- @param host string: Hostname or IP address of the server.
-- @param port number: Port number to use (default 80).
-- @param url string: URL path to access on the server.
-- @param cb function: Callback function to execute with response data.
-- @return none
function M.get(host, port, url, cb)
        --- Execute cURL command in a new job.
        local cmd = "curl --silent --no-buffer --fail-with-body http://" .. host .. ":" .. tostring(port) .. url
        return vim.fn.jobstart(cmd, {
                -- Callback function to execute with stdout data.
                on_stdout = function(_, data, _)
                        cb(data)
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
                                M.status = b
                        end
                end
        })
end

function M.post(host, port, url, content, cb)
        --- Execute cURL command in a new job.
        local cmd = "curl --silent --no-buffer --fail-with-body -X POST http://" .. host ..
            ":" .. port .. url .. " -d " .. vim.fn.shellescape(vim.json.encode(content)) .. ""

        return vim.fn.jobstart(cmd, {
                -- Callback function to execute with stdout data.
                on_stdout = function(_, data, _)
                        cb(data)
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
end

local errors = {
        {
                code = 0,
                name = "CURLE_OK",
                description = "All fine. Proceed as usual.",
                message = "Operation completed successfully.",
        },
        {
                code = 1,
                name = "CURLE_UNSUPPORTED_PROTOCOL",
                description = "The URL you passed to libcurl used a protocol that this libcurl does not support.",
                message = "Unsupported protocol error.",
        },
        {
                code = 2,
                name = "CURLE_FAILED_INIT",
                description =
                "Early initialization code failed. This is likely to be an internal error or problem, or a resource problem where something fundamental could not get done at init time.",
                message = "Initialization failed.",
        },
        {
                code = 3,
                name = "CURLE_URL_MALFORMAT",
                description = "The URL was not properly formatted.",
                message = "Invalid URL format.",
        },
        {
                code = 4,
                name = "CURLE_NOT_BUILT_IN",
                description =
                "A requested feature, protocol or option was not found built-in in this libcurl due to a build-time decision.",
                message = "Feature not available.",
        },
        {
                code = 5,
                name = "CURLE_COULDNT_RESOLVE_PROXY",
                description = "Could not resolve proxy. The given proxy host could not be resolved.",
                message = "Proxy resolution failed.",
        },
        {
                code = 6,
                name = "CURLE_COULDNT_RESOLVE_HOST",
                description = "Could not resolve host. The given remote host was not resolved.",
                message = "Host resolution failed.",
        },
        {
                code = 7,
                name = "CURLE_COULDNT_CONNECT",
                description = "Failed to connect() to host or proxy.",
                message = "Connection failed.",
        },
        {
                code = 8,
                name = "CURLE_WEIRD_SERVER_REPLY",
                description =
                "The server sent data libcurl could not parse. This error code was known as CURLE_FTP_WEIRD_SERVER_REPLY before 7.51.0.",
                message = "Server replied with invalid data.",
        },
        {
                code = 9,
                name = "CURLE_REMOTE_ACCESS_DENIED",
                description =
                "We were denied access to the resource given in the URL. For FTP, this occurs while trying to change to the remote directory.",
                message = "Access to resource denied.",
        },
        {
                code = 10,
                name = "CURLE_FTP_ACCEPT_FAILED",
                description =
                "While waiting for the server to connect back when an active FTP session is used, an error code was sent over the control connection or similar.",
                message = "FTP accept failed.",
        },
        {
                code = 11,
                name = "CURLE_FTP_WEIRD_PASS_REPLY",
                description =
                "After having sent the FTP password to the server, libcurl expects a proper reply. This error code indicates that an unexpected code was returned.",
                message = "Invalid FTP password response.",
        },
        {
                code = 12,
                name = "CURLE_FTP_ACCEPT_TIMEOUT",
                description =
                "During an active FTP session while waiting for the server to connect, the CURLOPT_ACCEPTTIMEOUT_MS (or the internal default) timeout expired.",
                message = "FTP accept timed out.",
        },
        {
                code = 13,
                name = "CURLE_FTP_WEIRD_PASV_REPLY",
                description =
                "libcurl failed to get a sensible result back from the server as a response to either a PASV or a EPSV command. The server is flawed.",
                message = "Invalid FTP PASV reply.",
        },
        {
                code = 14,
                name = "CURLE_FTP_WEIRD_227_FORMAT",
                description =
                "FTP servers return a 227-line as a response to a PASV command. If libcurl fails to parse that line, this return code is passed back.",
                message = "Invalid FTP 227 format.",
        },
        {
                code = 15,
                name = "CURLE_FTP_CANT_GET_HOST",
                description = "An internal failure to lookup the host used for the new connection.",
                message = "Failed to get host.",
        },
        {
                code = 16,
                name = "CURLE_HTTP2",
                description =
                "A problem was detected in the HTTP2 framing layer. This is somewhat generic and can be one out of several problems, see the error buffer for details.",
                message = "HTTP2 error.",
        },
        {
                code = 17,
                name = "CURLE_FTP_COULDNT_SET_TYPE",
                description = "Received an error when trying to set the transfer mode to binary or ASCII.",
                message = "Failed to set FTP transfer type.",
        },
        {
                code = 18,
                name = "CURLE_PARTIAL_FILE",
                description =
                "A file transfer was shorter or larger than expected. This happens when the server first reports an expected transfer size, and then delivers data that does not match the previously given size.",
                message = "File transfer incomplete.",
        },
        {
                code = 19,
                name = "CURLE_FTP_COULDNT_RETR_FILE",
                description = "This was either a weird reply to a 'RETR' command or a zero byte transfer complete.",
                message = "Failed to retrieve FTP file.",
        },
        {
                code = 20,
                name = "Obsolete error (not used in modern versions)",
                description = "Not used in modern versions.",
                message = "This error code is no longer used.",
        },
        {
                code = 21,
                name = "CURLE_QUOTE_ERROR",
                description =
                'When sending custom "QUOTE" commands to the remote server, one of the commands returned an error code that was 400 or higher (for FTP) or otherwise indicated unsuccessful completion of the command.',
                message = "Quote operation failed: invalid response from FTP server",
        },
        {
                code = 22,
                name = "CURLE_HTTP_RETURNED_ERROR",
                description =
                "This is returned if CURLOPT_FAILONERROR is set TRUE and the HTTP server returns an error code that is >= 400.",
                message = "HTTP request failed with status code %d: %s",
        },
        {
                code = 23,
                name = "CURLE_WRITE_ERROR",
                description =
                "An error occurred when writing received data to a local file, or an error was returned to libcurl from a write callback.",
                message = "Failed to write data to local file",
        },
        {
                code = 24,
                name = "Obsolete error (24)",
                description = "Not used in modern versions.",
                message = "Deprecated error: not used in current version of libcurl",
        },
        {
                code = 25,
                name = "CURLE_UPLOAD_FAILED",
                description =
                "Failed starting the upload. For FTP, the server typically denied the STOR command. The error buffer usually contains the server's explanation for this.",
                message = "Upload failed: invalid response from FTP server",
        },
        {
                code = 26,
                name = "CURLE_READ_ERROR",
                description = "There was a problem reading a local file or an error returned by the read callback.",
                message = "Failed to read data from local file",
        },
        {
                code = 27,
                name = "CURLE_OUT_OF_MEMORY",
                description =
                "A memory allocation request failed. This is serious badness and things are severely screwed up if this ever occurs.",
                message = "Out of memory: unable to allocate %d bytes",
        },
        {
                code = 28,
                name = "CURLE_OPERATION_TIMEDOUT",
                description = "Operation timeout. The specified time-out period was reached according to the conditions.",
                message = "Timeout: operation timed out after %ds",
        },
        {
                code = 29,
                name = "Obsolete error (29)",
                description = "Not used in modern versions.",
                message = "Deprecated error: not used in current version of libcurl",
        },
        {
                code = 30,
                name = "CURLE_FTP_PORT_FAILED",
                description =
                "The FTP PORT command returned error. This mostly happens when you have not specified a good enough address for libcurl to use. See CURLOPT_FTPPORT.",
                message = "FTP PORT command failed: invalid response from server",
        },
        {
                code = 31,
                name = "CURLE_FTP_COULDNT_USE_REST",
                description = "The FTP REST command returned error. This should never happen if the server is sane.",
                message = "FTP REST command failed: invalid response from server",
        },
        {
                code = 32,
                name = "Obsolete error (32)",
                description = "Not used in modern versions.",
                message = "Deprecated error: not used in current version of libcurl",
        },
        {
                code = 33,
                name = "CURLE_RANGE_ERROR",
                description = "The server does not support or accept range requests.",
                message = "Server does not support Range requests",
        },
        {
                code = 34,
                name = "CURLE_HTTP_POST_ERROR",
                description = "This is an odd error that mainly occurs due to internal confusion.",
                message = "HTTP POST request failed with status code %d: %s",
        },
        {
                code = 35,
                name = "CURLE_SSL_CONNECT_ERROR",
                description =
                "A problem occurred somewhere in the SSL/TLS handshake. You really want the error buffer and read the message there as it pinpoints the problem slightly more. Could be certificates (file formats, paths, permissions), passwords, and others.",
                message = "SSL/TLS connection failed: %s",
        },
        {
                code = 36,
                name = "CURLE_BAD_DOWNLOAD_RESUME",
                description =
                "The download could not be resumed because the specified offset was out of the file boundary.",
                message = "Failed to resume download at offset %d: out of range",
        },
        {
                code = 37,
                name = "CURLE_FILE_COULDNT_READ_FILE",
                description =
                "A file given with FILE:// could not be opened. Most likely because the file path does not identify an existing file. Did you check file permissions?",
                message = "Failed to open local file at %s: permission denied",
        },
        {
                code = 38,
                name = "CURLE_LDAP_CANNOT_BIND",
                description = "LDAP cannot bind. LDAP bind operation failed.",
                message = "LDAP bind operation failed: unable to authenticate user",
        },
        {
                code = 39,
                name = "CURLE_LDAP_SEARCH_FAILED",
                description = "LDAP search failed.",
                message = "LDAP search operation failed: %s",
        },
        {
                code = 40,
                name = "Obsolete error (40)",
                description = "Not used in modern versions.",
                message = "Deprecated error: not used in current version of libcurl",
        },
        {
                code = 41,
                name = "CURLE_FUNCTION_NOT_FOUND",
                description = "Function not found. A required zlib function was not found.",
                message = "Required zlib function not found: unable to decompress data",
        },
        {
                code = 42,
                name = "CURLE_ABORTED_BY_CALLBACK",
                description = 'Aborted by callback. A callback returned "abort" to libcurl.',
                message = "Callback aborted the operation.",
        },
        {
                code = 43,
                name = "CURLE_BAD_FUNCTION_ARGUMENT",
                description = "A function was called with a bad parameter.",
                message = "Invalid argument passed to a function.",
        },
        {
                code = 44,
                name = "Obsolete error (44)",
                description = "Not used in modern versions.",
                message = "This error is no longer used and can be ignored.",
        },
        {
                code = 45,
                name = "CURLE_INTERFACE_FAILED",
                description =
                "Interface error. A specified outgoing interface could not be used. Set which interface to use for outgoing connections' source IP address with CURLOPT_INTERFACE.",
                message = "Failed to set the outgoing interface.",
        },
        {
                code = 46,
                name = "Obsolete error (46)",
                description = "Not used in modern versions.",
                message = "This error is no longer used and can be ignored.",
        },
        {
                code = 47,
                name = "CURLE_TOO_MANY_REDIRECTS",
                description =
                "Too many redirects. When following redirects, libcurl hit the maximum amount. Set your limit with CURLOPT_MAXREDIRS.",
                message = "Maximum number of redirects exceeded.",
        },
        {
                code = 48,
                name = "CURLE_UNKNOWN_OPTION",
                description =
                "An option passed to libcurl is not recognized/known. Refer to the appropriate documentation. This is most likely a problem in the program that uses libcurl. The error buffer might contain more specific information about which exact option it concerns.",
                message = "Unknown option passed to libcurl.",
        },
        {
                code = 49,
                name = "CURLE_SETOPT_OPTION_SYNTAX",
                description =
                "An option passed in to a setopt was wrongly formatted. See error message for details about what option.",
                message = "Invalid syntax for the specified option.",
        },
        {
                code = 50,
                name = "Obsolete errors (50-51)",
                description = "Not used in modern versions.",
                message = "These errors are no longer used and can be ignored.",
        },
        {
                code = 51,
                name = "Obsolete error (51)",
                description = "Not used in modern versions.",
                message = "This error is no longer used and can be ignored.",
        },
        {
                code = 52,
                name = "CURLE_GOT_NOTHING",
                description =
                "Nothing was returned from the server, and under the circumstances, getting nothing is considered an error.",
                message = "No response received from the server.",
        },
        {
                code = 53,
                name = "CURLE_SSL_ENGINE_NOTFOUND",
                description = "The specified crypto engine was not found.",
                message = "Failed to initialize SSL engine.",
        },
        {
                code = 54,
                name = "CURLE_SSL_ENGINE_SETFAILED",
                description = "Failed setting the selected SSL crypto engine as default.",
                message = "Failed to set the selected SSL engine.",
        },
        {
                code = 55,
                name = "CURLE_SEND_ERROR",
                description = "Failed sending network data.",
                message = "Error sending data over the network.",
        },
}

return M
