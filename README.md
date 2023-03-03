# Groom your app’s Zig environment with zigenv.

Use zigenv to pick a Zig version for your application and guarantee
that your development environment matches production. Put zigenv to work
with [npm](https://www.npmjs.com/) for painless Zig upgrades and
bulletproof deployments.

**Powerful in development.** Specify your app's Zig version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of Zig. Just Works™
  from the command line. Override the Zig version anytime: just set
  an environment variable.

**Rock-solid in production.** Your application's executables are its
  interface with ops. With zigenv and you'll never again need to `cd`
  in a cron job or Chef recipe to ensure you've selected the right runtime.
  The Zig version dependency lives in one place—your app—so upgrades and
  rollbacks are atomic, even when you switch versions.

**One thing well.** zigenv is concerned solely with switching Zig
  versions. It's simple and predictable. A rich plugin ecosystem lets
  you tailor it to suit your needs. Compile your own Zig versions, or
  use the [node-build][]
  plugin to automate the process. Specify per-application environment
  variables with [zigenv-vars](https://github.com/zigenv/zigenv-vars).
  See more [plugins on the
  wiki](https://github.com/zigenv/zigenv/wiki/Plugins).

[**Why choose zigenv?**](https://github.com/zigenv/zigenv/wiki/Why-zigenv%3F)

## Table of Contents

<!-- toc -->

- [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Zig Version](#choosing-the-node-version)
  * [Locating the Zig Installation](#locating-the-node-installation)
- [Installation](#installation)
  * [Homebrew on macOS](#homebrew-on-macos)
    + [Upgrading with Homebrew](#upgrading-with-homebrew)
  * [Basic GitHub Checkout](#basic-github-checkout)
    + [Upgrading with Git](#upgrading-with-git)
    + [Updating the list of available Zig versions](#updating-the-list-of-available-node-versions)
  * [How zigenv hooks into your shell](#how-zigenv-hooks-into-your-shell)
  * [Installing Zig versions](#installing-node-versions)
  * [Uninstalling Zig versions](#uninstalling-node-versions)
  * [Uninstalling zigenv](#uninstalling-zigenv)
- [Command Reference](#command-reference)
  * [zigenv local](#zigenv-local)
  * [zigenv global](#zigenv-global)
  * [zigenv shell](#zigenv-shell)
  * [zigenv versions](#zigenv-versions)
  * [zigenv version](#zigenv-version)
  * [zigenv rehash](#zigenv-rehash)
  * [zigenv which](#zigenv-which)
  * [zigenv whence](#zigenv-whence)
- [Environment variables](#environment-variables)
- [Development](#development)
  * [Credits](#credits)

<!-- tocstop -->

## How It Works

At a high level, zigenv intercepts Zig commands using shim
executables injected into your `PATH`, determines which Zig version
has been specified by your application, and passes your commands along
to the correct Zig installation.

### Understanding PATH

When you run a command like `node` or `npm`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

zigenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.zigenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, zigenv maintains shims in that
directory to match every Zig command across every installed version
of Zig—`node`, `npm`, and so on.

Shims are lightweight executables that simply pass your command along
to zigenv. So with zigenv installed, when you run, say, `npm`, your
operating system will do the following:

* Search your `PATH` for an executable file named `npm`
* Find the zigenv shim named `npm` at the beginning of your `PATH`
* Run the shim named `npm`, which in turn passes the command along to
  zigenv

### Choosing the Zig Version

When you execute a shim, zigenv determines which Zig version to use by
reading it from the following sources, in this order:

1. The `ZIGENV_VERSION` environment variable, if specified. You can use
   the [`zigenv shell`](#zigenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.zig-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.zig-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.zig-version` file in the current working
   directory with the [`zigenv local`](#zigenv-local) command.

4. The global `~/.zigenv/version` file. You can modify this file using
   the [`zigenv global`](#zigenv-global) command. If the global version
   file is not present, zigenv assumes you want to use the "system"
   Zig—i.e. whatever version would be run if zigenv weren't in your
   path.

### Locating the Zig Installation

Once zigenv has determined which version of Zig your application has
specified, it passes the command along to the corresponding Zig
installation.

Each Zig version is installed into its own directory under
`~/.zigenv/versions`. For example, you might have these versions
installed:

* `~/.zigenv/versions/0.10.36/`
* `~/.zigenv/versions/0.12.0/`
* `~/.zigenv/versions/iojs-1.0.0/`

Version names to zigenv are simply the names of the directories or symlinks in
`~/.zigenv/versions`.

## Installation

### Homebrew on macOS

If you're on macOS, we recommend installing zigenv with
[Homebrew](https://brew.sh).

1. Install zigenv.

    ~~~ sh
    $ brew install zigenv
    ~~~

   Note that this also installs `node-build`, so you'll be ready to
   install other Zig versions out of the box.

2. Set up zigenv in your shell.

    ~~~ sh
    $ eval "$(zigenv init -)"
    ~~~

   Append the above line to your shell's rc/profile file and restart your shell.

   For shell-specific instructions to [set up zigenv shell integration](#how-zigenv-hooks-into-your-shell),
   run `zigenv init`.

3. Close your Terminal window and open a new one so your changes take
   effect.

4. Verify that zigenv is properly set up using this [zigenv-doctor][] script:

    ~~~ sh
    $ curl -fsSL https://github.com/zigenv/zigenv-installer/raw/master/bin/zigenv-doctor | bash
    Checking for `zigenv' in PATH: /usr/local/bin/zigenv
    Checking for zigenv shims in PATH: OK
    Checking `zigenv install' support: /usr/local/bin/zigenv-install (node-build 3.0.22-4-g49c4cb9)
    Counting installed Zig versions: none
      There aren't any Zig versions installed under `~/.zigenv/versions'.
      You can install Zig versions like so: zigenv install 2.2.4
    Auditing installed plugins: OK
    ~~~

5. That's it! Installing zigenv includes node-build, so now you're ready to
   [install some other Zig versions](#installing-node-versions) using
   `zigenv install`.


#### Upgrading with Homebrew

To upgrade to the latest zigenv and update node-build with newly released
Zig versions, upgrade the Homebrew packages:

~~~ sh
$ brew upgrade zigenv node-build
~~~


### Basic GitHub Checkout

For a more automated install, you can use [zigenv-installer][].
If you prefer a manual approach, follow the steps below.

This will get you going with the latest version of zigenv without needing
a systemwide install.

1. Clone zigenv into `~/.zigenv`.


    ~~~ sh
    $ git clone https://github.com/zigenv/zigenv.git ~/.zigenv
    ~~~

    Optionally, try to compile dynamic bash extension to speed up zigenv. Don't
    worry if it fails; zigenv will still work normally:

    ~~~
    $ cd ~/.zigenv && src/configure && make -C src
    ~~~

2. Add `~/.zigenv/bin` to your `$PATH` for access to the `zigenv`
   command-line utility.

   * For **bash**:
     ~~~ bash
     $ echo 'export PATH="$HOME/.zigenv/bin:$PATH"' >> ~/.bash_profile
     ~~~

   * For **Ubuntu Desktop** and **Windows Subsystem for Linux (WSL)**:
     ~~~ bash
     $ echo 'export PATH="$HOME/.zigenv/bin:$PATH"' >> ~/.bashrc
     ~~~

   * For **Zsh**:
     ~~~ zsh
     $ echo 'export PATH="$HOME/.zigenv/bin:$PATH"' >> ~/.zshrc
     ~~~

   * For **Fish shell**:
     ~~~ fish
     $ set -Ux fish_user_paths $HOME/.zigenv/bin $fish_user_paths
     ~~~

3. Set up zigenv in your shell.

   ~~~ sh
   $ ~/.zigenv/bin/zigenv init
   ~~~

   Follow the printed instructions to [set up zigenv shell integration](#how-zigenv-hooks-into-your-shell).

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.)

5. Verify that zigenv is properly set up using this [zigenv-doctor][] script:

    ~~~ sh
    $ curl -fsSL https://github.com/zigenv/zigenv-installer/raw/master/bin/zigenv-doctor | bash
    Checking for `zigenv' in PATH: /usr/local/bin/zigenv
    Checking for zigenv shims in PATH: OK
    Checking `zigenv install' support: /usr/local/bin/zigenv-install (node-build 3.0.22-4-g49c4cb9)
    Counting installed Zig versions: none
      There aren't any Zig versions installed under `~/.zigenv/versions'.
      You can install Zig versions like so: zigenv install 2.2.4
    Auditing installed plugins: OK
    ~~~

6. _(Optional)_ Install [node-build][], which provides the
   `zigenv install` command that simplifies the process of
   [installing new Zig versions](#installing-node-versions).

#### Upgrading with Git

If you've installed zigenv manually using Git, you can upgrade to the
latest version by pulling from GitHub:

~~~ sh
$ cd ~/.zigenv
$ git pull
~~~

To use a specific release of zigenv, check out the corresponding tag:

~~~ sh
$ cd ~/.zigenv
$ git fetch
$ git checkout v0.3.0
~~~

Alternatively, check out the [zigenv-update][] plugin which provides a
command to update zigenv along with all installed plugins.

~~~ sh
$ zigenv update
~~~

#### Updating the list of available Zig versions

If you're using the `zigenv install` command, then the list of available Zig versions is not automatically updated when pulling from the zigenv repo.
To do this manually:

~~~ sh
$ cd ~/.zigenv/plugins/node-build
$ git pull
~~~

### How zigenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`zigenv init` is the only command that crosses the line of loading
extra commands into your shell. Here's what `zigenv init` actually does:

1. Sets up your shims path. This is the only requirement for zigenv to
   function properly. You can do this by hand by prepending
   `~/.zigenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.zigenv/completions/zigenv.bash` will set that
   up. There is also a `~/.zigenv/completions/zigenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `zigenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   zigenv and plugins to change variables in your current shell, making
   commands like `zigenv shell` possible. The sh dispatcher doesn't do
   anything invasive like override `cd` or hack your shell prompt, but if
   for some reason you need `zigenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `zigenv init -` for yourself to see exactly what happens under the
hood.

### Installing Zig versions

The `zigenv install` command doesn't ship with zigenv out of the box, but is
provided by the [node-build][] project. If you installed it as part of GitHub
checkout process outlined above you should be able to:

~~~ sh
# list all available versions:
$ zigenv install -l

# install a Zig version:
$ zigenv install 0.10.26
~~~

Alternatively to the `install` command, you can download and compile
Zig manually as a subdirectory of `~/.zigenv/versions/`. An entry in
that directory can also be a symlink to a Zig version installed
elsewhere on the filesystem. zigenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Zig version.
Additionally, `zigenv` has special support for an `lts/` subdirectory inside
`versions/`. This works great with the
[`zigenv-aliases`](https://github.com/zigenv/zigenv-aliases) plugin, for example:

~~~ sh
$ cd ~/.zigenv/versions
$ mkdir lts

# Create a symlink that allows to use "lts/erbium" as a zigenv version
# that always points to the latest Zig 12 version that is installed.
$ ln -s ../12 lts/erbium
~~~

### Uninstalling Zig versions

As time goes on, Zig versions you install will accumulate in your
`~/.zigenv/versions` directory.

To remove old Zig versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Zig version with the `zigenv prefix` command, e.g. `zigenv prefix
0.8.22`.

The [node-build][] plugin provides an `zigenv uninstall` command to
automate the removal process.

### Uninstalling zigenv

The simplicity of zigenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** zigenv managing your Zig versions, simply remove the
  `zigenv init` line from your shell startup configuration. This will
  remove zigenv shims directory from `$PATH`, and future invocations like
  `node` will execute the system Zig version, as before zigenv.

  `zigenv` will still be accessible on the command line, but your Zig
  apps won't be affected by version switching.

2. To completely **uninstall** zigenv, perform step (1) and then remove
   its root directory. This will **delete all Zig versions** that were
   installed under `` `zigenv root`/versions/ `` directory:

        rm -rf `zigenv root`

   If you've installed zigenv using a package manager, as a final step
   perform the zigenv package removal. For instance, for Homebrew:

        brew uninstall zigenv

## Command Reference

Like `git`, the `zigenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### zigenv local

Sets a local application-specific Zig version by writing the version
name to a `.zig-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `ZIGENV_VERSION` environment variable or with the `zigenv shell`
command.

    $ zigenv local 0.10.0

When run without a version number, `zigenv local` reports the currently
configured local version. You can also unset the local version:

    $ zigenv local --unset

### zigenv global

Sets the global version of Zig to be used in all shells by writing
the version name to the `~/.zigenv/version` file. This version can be
overridden by an application-specific `.zig-version` file, or by
setting the `ZIGENV_VERSION` environment variable.

    $ zigenv global 0.10.26

The special version name `system` tells zigenv to use the system Zig
(detected by searching your `$PATH`).

When run without a version number, `zigenv global` reports the
currently configured global version.

### zigenv shell

Sets a shell-specific Zig version by setting the `ZIGENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ zigenv shell 0.11.11

When run without a version number, `zigenv shell` reports the current
value of `ZIGENV_VERSION`. You can also unset the shell version:

    $ zigenv shell --unset

Note that you'll need zigenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`ZIGENV_VERSION` variable yourself:

    $ export ZIGENV_VERSION=0.10.26

### zigenv versions

Lists all Zig versions known to zigenv, and shows an asterisk next to
the currently active version.

    $ zigenv versions
      0.8.22
      0.9.12
      * 0.10.0 (set by /Users/will/.zigenv/version)

This will also list symlinks to specific Zig versions inside the `~/.zigenv/versions` or `~/.zigenv/versions/lts` directories.

### zigenv version

Displays the currently active Zig version, along with information on
how it was set.

    $ zigenv version
    0.10.0 (set by /Users/OiNutter/.zigenv/version)

### zigenv rehash

Installs shims for all Zig executables known to zigenv (i.e.,
`~/.zigenv/versions/*/bin/*` and `~/.zigenv/versions/lts/*/bin/*`). Run this command after you install a new
version of Zig, or install an npm package that provides an executable binary.

    $ zigenv rehash

_**note:** the [package-rehash plugin][package-rehash-plugin] automatically runs `zigenv rehash` whenever an npm package is installed globally_

### zigenv which

Displays the full path to the executable that zigenv will invoke when
you run the given command.

    $ zigenv which npm
    /Users/will/.zigenv/versions/0.10.26/bin/npm

### zigenv whence

Lists all Zig versions with the given command installed.

    $ zigenv whence npm
    0.10.0
    0.9.12
    0.8.22

## Environment variables

You can affect how zigenv operates with the following settings:

name | default | description
-----|---------|------------
`ZIGENV_VERSION` | | Specifies the Zig version to be used.<br>Also see [`zigenv shell`](#zigenv-shell)
`ZIGENV_ROOT` | `~/.zigenv` | Defines the directory under which Zig versions and shims reside.<br>Also see `zigenv root`
`ZIGENV_DEBUG` | | Outputs debug information.<br>Also as: `zigenv --debug <subcommand>`
`ZIGENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for zigenv hooks.
`ZIGENV_DIR` | `$PWD` | Directory to start searching for `.zig-version` files.

## Development

The zigenv source code is [hosted on
GitHub](https://github.com/zigenv/zigenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/zigenv/zigenv/issues).

### Credits

Forked from [Sam Stephenson](https://github.com/sstephenson)'s
[rbenv](https://github.com/rbenv/rbenv) by [Will
McKenzie](https://github.com/oinutter) and modified for node.


  [hooks]: https://github.com/rbenv/rbenv/wiki/Authoring-plugins#rbenv-hooks
  [node-build]: https://github.com/zigenv/node-build#readme
  [zigenv-doctor]: https://github.com/zigenv/zigenv-installer/blob/master/bin/zigenv-doctor
  [zigenv-installer]: https://github.com/zigenv/zigenv-installer#zigenv-installer
  [zigenv-update]: https://github.com/charlesbjohnson/zigenv-update
  [package-rehash-plugin]: https://github.com/zigenv/zigenv-package-rehash
