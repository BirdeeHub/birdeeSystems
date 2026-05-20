-- Vibe commenting to remind me how this s*** works

---@param sh Shelua
return function(sh, sherun)
    local escapeShellArg = getmetatable(sh).repr.posix.escape

    local function heredoc(s)
        local marker = "SHELUA_HEREDOC_EOF"
        while s:find(marker, 1, true) do
            marker = marker .. "_"
        end
        return ("{\ncat <<'%s'\n%s\n%s\n}"):format(marker, s, marker)
    end

    ---@type Shelua.Repr
    ---@diagnostic disable-next-line: missing-fields
    local posix_plus = {
        -- Reuse the base POSIX shell escaping (single-quote wrapping).
        escape = escapeShellArg,

        -- Standard key-value → flag translation (same as base posix).
        arg_tbl = function(opts, k, a)
            k = (#k > 1 and '--' or '-') .. k
            if type(a) == 'boolean' and a then return k end
            if type(a) == 'string' then return { k, escapeShellArg(a) } end
            if type(a) == 'number' then return { k, tostring(a) } end
            return nil
        end,

        -- Concatenate command + args into a shell string.
        add_args = function(opts, cmd, args)
            return cmd .. " " .. table.concat(args, ' ')
        end,

        -- Track extra result fields that trigger pipe resolution.
        extra_cmd_results = { "__stderr", },
    }

    --╔════════════════════════════════════════════════════════════╗
    --║  concat_cmd — build bash pipeline strings                  ║
    --║                                                            ║
    --║  Converts shelua pipe inputs into bash shell expressions:  ║
    --║    - string inputs → heredoc via cat <<'EOF'               ║
    --║    - command inputs → their c (command string)             ║
    --║    - AND operator → cmd1 && cmd2                           ║
    --║    - OR operator  → cmd1 || cmd2                           ║
    --║    - multiple inputs → { cmd1 ; cmd2 ; } | cmd             ║
    --╚════════════════════════════════════════════════════════════╝
    function posix_plus.concat_cmd(opts, cmd, input)
        -- Normalize a pipe input value into a shell expression string.
        -- v.c = prior command string (already a shell expression)
        -- v.s = prior stdout string (emit via heredoc)
        -- v.e = exit metadata (__exitcode, __stderr, etc.)
        local function normalize_shell_expr(v, cmd_mod)
            if v.c then return v.c end
            -- If this is an AND/OR modifier and the prior command failed,
            -- emit to stderr and return false.
            if v.s and cmd_mod and (v.e.__exitcode or 0) ~= 0 then
                return "{ " .. heredoc(v.e.__stderr or v.s) .. " 1>&2; false; }"
            end
            return heredoc(v.s)
        end

        -- AND: cmd1 && cmd2 (run cmd2 only if cmd1 succeeds)
        if cmd:sub(1, 3) == "AND" then
            local initial = normalize_shell_expr(input[1], "AND")
            local res = {}
            for i = 2, #input do
                table.insert(res, normalize_shell_expr(input[i]))
            end
            if #res == 0 then error("AND requires at least 2 commands") end
            if #res == 1 then return initial .. " && " .. res[1] end
            return initial .. " && { " .. table.concat(res, " ; ") .. " ; }"

        -- OR: cmd1 || cmd2 (run cmd2 only if cmd1 fails)
        elseif cmd:sub(1, 2) == "OR" then
            local initial = normalize_shell_expr(input[1], "OR")
            local res = {}
            for i = 2, #input do
                table.insert(res, normalize_shell_expr(input[i]))
            end
            if #res == 0 then error("OR requires at least 2 commands") end
            if #res == 1 then return initial .. " || " .. res[1] end
            return initial .. " || { " .. table.concat(res, " ; ") .. " ; }"

        -- Single input: pipe into this command with |
        elseif #input == 1 then
            return normalize_shell_expr(input[1]) .. " | " .. cmd

        -- Multiple inputs: group with {} and pipe combined output
        elseif #input > 1 then
            for i, v in ipairs(input) do
                ---@diagnostic disable-next-line: assign-type-mismatch
                input[i] = normalize_shell_expr(v)
            end
            return "{ " .. table.concat(input, " ; ") .. " ; } | " .. cmd

        -- No input: just the command as-is
        else
            return cmd
        end
    end

    posix_plus.proper_pipes = true
    -- TODO: support || (OR) and && (AND) without setting proper_pipes
    function posix_plus.single_stdin(opts, cmd, inputs, codes)
        if inputs and #inputs > 0 then
            cmd = heredoc(table.concat(inputs)) .. " | " .. cmd
        end
        return cmd, {}
    end

    posix_plus.run_cmd = function (opts, cmd, msg)
        local result = sherun({ "bash" }, { cwd = opts.cwd or nil, env = opts.env or nil, stdin = cmd, text = true }):wait()
        return {
            __input = result.stdout,
            __stderr = result.stderr,
            __exitcode = result.code,
            __signal = result.signal,
        }
    end
    return posix_plus
end
