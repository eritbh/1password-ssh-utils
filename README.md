> [!important]
> This tool is no longer being worked on. It's based on the deprecated 1Password CLI v1 which may not work anymore. You probably want to migrate to [the 1Password SSH Agent](https://developer.1password.com/docs/ssh/) instead of using these scripts (though [their recommended workarounds for managing per-host keys](https://developer.1password.com/docs/ssh/agent/advanced/#match-key-with-host) aren't the best, and could probably be improved with additional scripting).

# 1password-ssh-utils

Utilities for storing and loading SSH keys with 1Password. Use a unique key for every host you connect to, without worrying about keeping them straight across your local machines.

## Installation

### Dependencies

- [1Password CLI v1][1password-cli-v1]
- [jq][jq]

These executables (`op` and `jq`) must be available on `PATH`.

You should run `op signin` at least once before using these scripts in order to cache your basic account information. See ["1Password Accounts"](#1password-accounts) for more information.

[1password-cli-v1]: https://app-updates.agilebits.com/product_history/CLI
[jq]: https://stedolan.github.io/jq/

### Adding the scripts

Clone the repo anywhere on your computer and add the `bin` folder to your `PATH`. For example, with bash:

    git clone https://github.com/eritbh/1password-ssh-utils.git ~/.1password-ssh-utils
    echo 'export PATH="$HOME/.1password-ssh-utils/bin:$PATH"' >> ~/.bashrc

### Setting up your SSH config

The fetch utility stores your keys in a dedicated directory, ideally one that will not be written to disk. It also creates an SSH config file that maps the host and username specified for each key to the fetched key file. In order to use theses keys for authentication, you must include the generated config file in your own local config via an `Include` directive. For example:

    Include /dev/shm/op-ssh-utils/ssh_config

Note that the path to this file may be different on systems where `/dev/shm` is not available; see [the "Environment" section](#environment) for more information.

### Automatically fetch keys before using SSH

In many shells, you can define an alias for the `ssh` command which ensures your keys are fetched before connecting to a server, like so:

    alias ssh="op-ssh-fetch -n && ssh"

## Usage

Note that non-interactive execution is not supported for any of these scripts, since `op signin` is required for all scripts and itself requires interactive password input.

### Create a new SSH item in the vault

    $ op-ssh-create -H <hostname>

Create a new vault item associated with the given host and the current username, generating a new SSH key specifically for that user on that host, and optionally register the new key for local use.

- Use `-u user` to log into the host as `user` rather than your current username. **TODO:** `-H hostname` should NOT be given in `user@host` format right now because I don't know quite enough sed magic to parse things like that.
- Use `-i ~/.ssh/id_rsa` to use an existing keypair, `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`, instead of generating a new keypair.

### Pull all SSH items in the vault for use locally

    $ op-ssh-fetch

Search for SSH key items in your vault and register them for local use.

- Use `-n` to do nothing if keys already exist. This is useful for shell aliases to only display the password prompt once per login.

### Remove all local SSH credentials

    $ op-ssh-remove

Completely deletes the storage directory, undoing `op-ssh-fetch`.

## Environment

The location where keys and the temporary SSH config file are stored is given by the `OP_SSH_STORAGEDIR` environment variable, defaulting to `$TMPDIR/op-ssh-utils`. The `TMPDIR` environment variable defaults to `/dev/shm` or `/tmp`, whichever is available. `/dev/shm` is preferred since it is guaranteed to hold keys in memory, whereas `/tmp` may write to disk on some systems. Particularly if `/dev/shm` is not available, you may wish to mount your own `tmpfs` filesystem somewhere else and point `TMPDIR` to that location instead.

Within this location, the SSH config file is stored in `ssh_config`, and key pairs are stored in the `keys` subdirectory according to the UUID of their associated 1Password item.

## 1Password Accounts

Normally, running `op signin` at least once before using these scripts caches some of your 1Password account details in your home directory. This cached account is what this script will attempt to log in as by default. The full invocation may look something like this:

    eval $(op signin my.1password.com you@email.com YOUR-SECRET-KEY)

If you would like to use a different account for this script than the cached one, you can pass additional arguments to `op-ssh-fetch` and `op-ssh-create` which will be passed through directly to `op signin`. For example:

    op-ssh-fetch my.1password.com you@email.com YOUR-SECRET-KEY

See `op signin --help` for details about what arguments are expected.
