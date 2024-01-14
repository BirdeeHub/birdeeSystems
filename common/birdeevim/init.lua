-- print(debug.getinfo(1, "S").source:sub(2))
if nixCats('nixCats_packageName') ~= "minimal" then
  if vim.g.vscode == nil then
    require("birdee")
  else
    -- a stripped down version for embedding
    require('vscody')
  end
end
