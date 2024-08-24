> [!NOTE]
> THIS IS NOT A DISTRIBUTION! IT IS MINE.
> If you have an issue using it, provide an actionable fix, or get your own XD

see:

[nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim)

This neovim config is based on this template:

[nixCats-nvim#nixExpressionFlakeOutputs](https://github.com/BirdeeHub/nixCats-nvim/tree/main/nix/templates/nixExpressionFlakeOutputs)

You can run it with `nix shell github:BirdeeHub/birdeeSystems#noAInvim` and then typing `vi`, `vim`, or `noAInvim`.

> [!NOTE]
> Keep in mind downloading my config is going to download a lot of lsps and plugins.
> You should use the noAI one because otherwise it would throw an error because you dont have my key and also it wont download bitwarden cli for you.

(completion keys are `<M-h>` = `<esc>` `<M-j>` = `next` `<M-k>` = `previous` `<M-l>` = `accept`, you have been warned.)

---

It uses [`lze`](https://github.com/BirdeeHub/lze) for lazy loading, which is my fork of [`lz.n`](https://github.com/nvim-neorocks/lz.n).

[`lze`](https://github.com/BirdeeHub/lze)'s plugin spec is a valid superset of the [`lz.n`](https://github.com/nvim-neorocks/lz.n) plugin spec.

Meaning if you use [rocks-lazy.nvim](https://github.com/nvim-neorocks/rocks-lazy.nvim) you could do `package.loaded['lz.n'] = require('lze')`
and it would work exactly as if it was lz.n because as of writing this, rocks-lazy simply translates stuff from the rocks toml file
into the plugin spec.

That being said there are a lot of things in this repo using [`lze`](https://github.com/BirdeeHub/lze) that would not be possible using [`lz.n`](https://github.com/nvim-neorocks/lz.n).

[`lze`](https://github.com/BirdeeHub/lze) does not aim to be the same as [`lz.n`](https://github.com/nvim-neorocks/lz.n), and as such, a large portion of its codebase is different.

[`lze`](https://github.com/BirdeeHub/lze) strives to be easier to extend, and to a further extent,
while still giving you more tools for dealing with edgecase plugins neatly, out of the box.

It exists because the custom handler feature I added to
lz.n was not handled at all as I had envisioned,
and I really didnt like the new changes,
but was not able to take part in deciding how it should be instead.

Regardless of how it came to be, I like my new version a lot. It does a lot of things I feel it always should have done.

[`lze`](https://github.com/BirdeeHub/lze) is still pending review to be added to nixpkgs, but can already be downloaded from luarocks, added as a flake, or just downloaded and added to the rtp somehow.
