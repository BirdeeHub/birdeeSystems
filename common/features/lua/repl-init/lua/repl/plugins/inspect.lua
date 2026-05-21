local inspect = require("inspect")
function override:displayresults(result)
    for _, v in ipairs(result) do
        if type((getmetatable(v) or {}).__tostring) == "function" or v.__input then
            io.stdout:write(tostring(v) .. "\n")
        else
            io.stdout:write(inspect(v) .. "\n")
        end
    end
end
