> [!NOTE]
> THIS IS NOT A DISTRIBUTION! IT IS MINE.
> If you have an issue using it, provide an actionable fix, or get your own XD

see:

[nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim)

This neovim config is based on this template:

[nixCats-nvim#nixExpressionFlakeOutputs](https://github.com/BirdeeHub/nixCats-nvim/tree/main/nix/templates/nixExpressionFlakeOutputs)

You can run it with `nix shell github:BirdeeHub/birdeeSystems#nvim_for_u` and then typing `vi`, `vim`, `nvim`, or `nvim_for_u`.

> [!NOTE]
> Keep in mind downloading my config is going to download a lot of lsps and plugins.
> You should use the nvim_for_u one because you dont have my key so you dont need the AI plugins, and it has more normal autocomplete keybinds

> [!WARNING]
> in the non-mentioned outputs,
> completion keys are `<M-h>` = `<esc>`, `<M-j>` = `next`, `<M-k>` = `previous`, `<M-l>` = `accept`.
> You have been warned.

---

It uses [`lze`](https://github.com/BirdeeHub/lze) for lazy loading, which has a very similar plugin spec to [`lz.n`](https://github.com/nvim-neorocks/lz.n).

- Is it faster? No its basically the same.

- Does it work completely differently from lz.n despite having more or less
the same spec fields?
  - Yes, although it shares some handler code where they parse their field from the spec.

`lze` is my take on `lz.n`
