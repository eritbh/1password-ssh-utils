# 1password-ssh-utils

Utilities for storing and loading SSH keys with 1password

## Usage

Note that interactive execution is not supported for any of these scripts, since `op signin` is required for all scripts and itself requires interactive password input.

By default, the key storage location is `$TMPDIR/op-ssh-utils`, where `TMPDIR` defaults to `/dev/shm` or `/tmp`, whichever is available. The key storage location can be overridden for all commands with the `OP_KEY_STORAGE_LOCATION` environment variable.

### Create a new SSH item in the vault

    $ ./op-create-identity -H <hostname>

Create a new vault item associated with the given host and the current username, generating a new SSH key specifically for that user on that host. It then optionally registers the new key for immediate local use.

- Use `-u user` to log into the host as `user` rather than your current username. `-H hostname` should NOT be given in `user@host` format right now because I don't know quite enough sed magic to parse things like that.
- Use `-i ~/.ssh/id_rsa` to use an existing keypair, `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`, instead of generating a new keypair.

### Pull all SSH items in the vault for use locally

    $ ./op-add-identities

Search for SSH key items in your vault and read them all into temporary storage. Public and private keys will be saved to `/tmp/op-ssh-utils/keys` with appropriate permissions, and an SSH config file will be saved to `/tmp/op-ssh-utils/ssh_config` which can be included from your personal SSH config (usually `~/.ssh/config`) via `Include /tmp/op-ssh-utils`.

### Remove all local SSH credentials

    $ rm -r /tmp/op-ssh-utils

# Todos

- Use a different temporary location to allow multiple users on the same system to use the tool (random folder names in the folder symlinked to `~/.local` or something? maybe just make it a bashrc script that automates adding the `Include` rule to the user's SSH config without requiring a persistent directory name across logins?)
- Better vault item searching/handling, customization of the item template
  - Guidance for adding items to 1Password manually so that this tool can pick them up
