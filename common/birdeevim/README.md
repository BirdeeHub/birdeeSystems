> [!NOTE]
> THIS IS NOT A DISTRIBUTION! IT IS MINE.
> If you have an issue using it, provide an actionable fix, or get your own XD

see:

[nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim)

This neovim config is based on this template:

[nixCats-nvim#nixExpressionFlakeOutputs](https://github.com/BirdeeHub/nixCats-nvim/tree/main/nix/templates/nixExpressionFlakeOutputs)

You can run it with `nix shell github:BirdeeHub/birdeeSystems#noAInvim` and then typing `vi`, `vim`, or `noAInvim`.

You can run one with just go, web, and nix stuff with `nix shell github:BirdeeHub/birdeeSystems#vigo` and then typing `vigo`.

> [!NOTE]
> Keep in mind downloading my config is going to download a lot of lsps and plugins.
> You should use the noAI or go one because otherwise it would throw an error because you dont have my key and also it wont download bitwarden cli for you.


> [!WARNING]
> (completion keys are `<M-h>` = `<esc>` `<M-j>` = `next` `<M-k>` = `previous` `<M-l>` = `accept`, you have been warned.)

---

It uses [`lze`](https://github.com/BirdeeHub/lze) for lazy loading, which is my fork of [`lz.n`](https://github.com/nvim-neorocks/lz.n).

[`lze`](https://github.com/BirdeeHub/lze)'s plugin spec is a valid superset of the [`lz.n`](https://github.com/nvim-neorocks/lz.n) plugin spec.

I will be transferring back to lz.n

Why? Because I was confidently incorrect.
