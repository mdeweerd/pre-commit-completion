# Bash completion for pre-commit

## Setup

Get `pre-commit.bash`.

### Source it in your shell

Source it into your shell (`.bashrc` or `.bash_profile`):

   ```bash
   source path/to/pre-commit.bash
   # or
   . path/to/pre-commit-completion.bash`
   ```

### Automatically source it

`install.sh` will copy the bash completion script to the appropriate directory in your home.

- The path was taken from `declare -f __load_completion` - it could give you another hint.
  It is loaded through the `_completion_loader()` function.
- Global installation may be possible by adding the files to one of these paths:
  - `/usr/local/share/bash_completion/completions`
  - `/usr/share/bash_completion/completions`

## Debugging

Debugging can be facilitated by calling `set -x`.\
To disable the trace, you can do the opposite: `set +x`.

## LICENSE

GNU GENERAL PUBLIC LICENSE - Version 3, 29 June 2007
