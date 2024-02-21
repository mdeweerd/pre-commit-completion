# Bash completion for pre-commit

Provides command line completion for pre-commit.

This is a "pure" bash shell implementation requiring only `grep` and `sed`.

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

## "Limitations"

- The hooks are extracted from the pre-commit configuration through a lookup of lines with `id:` or `alias:`.  There is no actual decoding of yaml.  This increases speed and it limits the need for extra tools.

## Other

- (Takishima/pre-commit-completion)[https://github.com/Takishima/pre-commit-completion] is another project that provides bash completion.  It is based on a compiled C program.

## LICENSE

GNU GENERAL PUBLIC LICENSE - Version 3, 29 June 2007
