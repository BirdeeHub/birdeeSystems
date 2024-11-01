local M = {}
M.for_cat = {
    spec_field = "for_cat",
    modify = function(plugin)
        if type(plugin.for_cat) == "table" then
            if plugin.for_cat.cat ~= nil then
                if vim.g[ [[nixCats-special-rtp-entry-nixCats]] ] ~= nil then
                    plugin.enabled = (nixCats(plugin.for_cat.cat) and true) or false
                else
                    plugin.enabled = nixCats(plugin.for_cat.default)
                end
            else
                plugin.enabled = (nixCats(plugin.for_cat) and true) or false
            end
        else
            plugin.enabled = (nixCats(plugin.for_cat) and true) or false
        end
        return plugin
    end,
}
return M
