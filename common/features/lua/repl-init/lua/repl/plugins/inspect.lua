local inspect = require("inspect")
function override:displayresults(result)
    for _, v in ipairs(result) do
        io.stderr:write(inspect(v) .. "\n")
    end
end
