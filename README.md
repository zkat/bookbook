# Bookbook

## Table of Contents

- [Features](#features)
- [Setting up](#setting-up)
  - [Prerequisites](#prerequisites)
    - [Using ASDF for Runtimes](#using-asdf-for-runtimes)
  - [Additional Tooling](#additional-tooling)
  - [Up and Running](#up-and-running)
- [Architecture](#architecture)

## Features

- User accounts, with authentication, login/signup, and email verification
- User settings page scaffold
- Primarily server-side rendered, with web components set up for if/when needed
- Web components are ALSO SSR'd as needed
- No Tailwind/React/etc. Just plain ol' HTML/CSS, a sprinkling of JS, and good vibes.
- TypeScript support
- Full setup for bundling and minifying JS and CSS from sources
- Ready-to-use i18n and locale detection/configuration
- Transactional email sending (needs a service for live site)
- Rate limiting
- Websockets available if needed (not connected by default)
- Autoformatting for both JSTS and Elixir code
- CSS-based light/dark/etc theming support with built-in picker
- Scaffolded CSP
- Ready-to-go DNS-based clustering for horizontal scaling (you don't need it)
- Root template with a bunch of nice things:
  - Mobile size-related meta tags
  - Anti-AI no-scan stuff (on top of included robots.txt). For all the good it'll do :/
  - OpenGraph/"Twitter" card properties, configurable per-page.

## Setting up

### Prerequisites

> [!TIP]
> See [Using ASDF for Runtimes](#using-asdf-for-runtimes) for a convenient way to handle the first two items below.

- [Elixir](https://elixir-lang.org/install.html) and Erlang (Typically auto-installs with Elixir)
- [NodeJS](https://nodejs.org/en/download/)
- [Postgresql v13 or later](https://wiki.postgresql.org/wiki/Detailed_installation_guides) ATM the tests require a postgres/postgres user/password to run. Check [this doc](https://academind.com/tutorials/postgresql-start-stop-uninstall-upgrade-server#resetting-the-root-user-password) for info on how to reset your postgres password.
  - A [docker-compose](./docker-compose.yaml) file is provided that will run
    postgres configured appropriately
- `inotify-tools` (Linux only) - Install through your preferred package manager
  - [Check versions here](https://github.com/zkat/bookbook/blob/main/.tool-versions)

> [!NOTE]
> You can check [`.tool-versions`](https://github.com/zkat/bookbook/blob/main/.tool-versions) in this repository to see what this project is typically developed against.

> [!IMPORTANT]
> If `postgresql` installed via `homebrew`, make sure to run `/usr/local/opt/postgres/bin/createuser -s postgres`.

#### Using ASDF for runtimes

You can use [ASDF](https://asdf-vm.com/) to install Elixir, Erlang, and NodejS
at the correct versions (ensure [the necessary build
deps](https://github.com/asdf-vm/asdf-erlang?tab=readme-ov-file#before-asdf-install)
are installed first):

```shell
asdf plugin add nodejs
asdf plugin add erlang
asdf plugin add elixir
KERL_BUILD_DOCS=yes asdf install # will install erlang (w/ docs), elixir, and nodejs
```

### Additional Tooling

If you're using VS Code, you may find these extensions useful:

- [ElixirLS extension](https://marketplace.visualstudio.com/items?itemName=JakeBecker.elixir-ls)
- [lit-plugin extension](https://marketplace.visualstudio.com/items?itemName=runem.lit-plugin)
- [gettext extension](https://marketplace.visualstudio.com/items?itemName=mrorz.language-gettext)
- [HTML CSS Support](https://marketplace.visualstudio.com/items?itemName=ecmel.vscode-html-css)
- [Dprint Code Formatter](https://marketplace.visualstudio.com/items?itemName=dprint.dprint)

### Up and Running

Just a couple more commands and we're all set:

- `mix local.hex` to install hex package manager
- `mix archive.install hex phx_new`
- If using docker postgres: `docker compose up -d`
- `mix setup` to install deps, create the database, install JS deps, and build JS assets
- `mix phx.server` to run the server

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Architecture

### Stack

#### Backend

- [Elixir](https://elixir-lang.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Phoenix](https://www.phoenixframework.org/) (no LiveView)

#### Frontend

- Plain old HTML + CSS (only preprocessing for CSS is bundling/minification)
- [Lit](https://lit.dev/) for dynamic components
- [TypeScript](https://www.typescriptlang.org/)

#### JS Considerations and SSR

We use TypeScript for all client-side code, and Lit for all client-side
components. Components should be small and focused, preferring to use
server-side Phoenix Components whenever possible.

We generate as much html/css as possible server-side, and try to keep our JS
payloads as small as possible. Server-side rendering, or SSR, is done in three
layers:

1. `Phoenix` controllers render a dynamic page with as much of the content in
   regular light DOM as possible. This content can be styled with our global
   CSS styles, and does not require JS to render/function.
   - This uses [`Phoenix HEEx templates and
Components`](https://hexdocs.pm/phoenix/components.html).
   - Within these templates, we can insert `Lit` components for things that
     will absolutely need dynamic, client-side/JS behavior or will otherwise
     have to do something special to function while offline.
2. Once `Phoenix` renders these templates, they're passed through the
   [`Plug`](https://hexdocs.pm/plug/readme.html) system, which eventually
   invokes a `Lit` server-side renderer.
   - This renderer takes the template, loads all existing components, and
     pre-renders `Lit` components as far as server-side work will allow.
   - In components, this behavior can be controlled with
     [`isServer`](https://lit.dev/docs/api/misc/#isServer).
3. Finally, all this server-side-rendered content is sent to the client, and
   `Lit` components will be "hydrated" after all the other content and JS is
   loaded.

As a general rule, we operate on "the less JavaScript, the better".
Dependencies should be few and far between, preferring to use built-in browser
features whenever possible. If a dependency is needed, it should be small and
focused, and not introduce a lot of overhead. Obviously, some things in
offline apps are just going to bring in some bulk and that's ok, but whenever
we have a choice between two things, code size should be a significant
consideration in their evaluation.

To minimize JavasScript, we should err on the side of having components be
`Phoenix`-based, and only use `Lit` components when absolutely necessary: even
if they're server-side rendered, their JavaScript definitions still needs to
load/hydrate, and are still shipped as part of our `.js` bundles.

To see what kind of weight a dependency brings in, you can use
[BundlePhobia](https://bundlephobia.com).

### Folder Structure

- `assets/` - Frontend code
  - `css/` - CSS files
    - `components/` - CSS for (usually server-side) components
    - `app.css` - main css entrypoint
    - `theme-*.css` - variables for themes
    - `variables.css` - non-theme-specific variables
      - NOTE: While regular styles don't leak into shadow DOM, `--variables`
        do, so we can use this for things we need to have consistent styling
        for.
  - `js/` - JS/TS files
    - `components/` - Toplevel lit components
    - `app.ts` - entry point for the overall site JS
    - `lit-ssr.ts` - lit server-side renderer tool. Used as a server-side script. Kept here for convenience.
    - Other files are pulled in by one of these.
- `config/` - Configuration files
  - Different configs for dev, prod, and test envs.
  - `config.exs` - common config
  - `runtime.exs` - more prod config
- `lib/` - Elixir source code
  - `bookbook/` - core business logic. No web stuff here. All modules are prefixed with `Bookbook`.
  - `bookbook_web/` - all web stuff here. Modules are prefixed with
    `BookbookWeb`. Uses `Bookbook` for any business logic.
- `priv/` - miscellaneous things
  - `gettext/` - this is where our (server-side) i18n stuff lives
  - `repo/` - migrations, seeds, etc
  - `static/` - static files. JS and CSS are compiled into here (but .gitignored)
