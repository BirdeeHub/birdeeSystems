local ctx = ...
local mons = ctx.final_mons

local function configure(i)
  local mon = mons[i]
  if i == 1 then
    os.sh.xrandr("--output", mon, "--primary", "--preferred")
  else
    local side = i % 2 == 0 and "--left-of" or "--right-of"
    local target = mons[math.floor(i / 2)]
    os.sh.xrandr("--output", mon, side, target, "--preferred")
  end
end

if ctx.boot then
  for i = 1, #mons do
    configure(i)
  end
else
  for _, mon in ipairs(ctx.newmons) do
    for i, finalmon in ipairs(mons) do
      if mon == finalmon then
        configure(i)
        break
      end
    end
  end
end
