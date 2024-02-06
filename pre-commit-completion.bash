# pre-commit completion script
# shellcheck disable=all  # disable for now

_pre_commit_completion() {
  local cur prev prev2 words cword

  _init_completion || return

  local commands="autoupdate clean gc init-templatedir install install-hooks migrate-config run sample-config try-repo uninstall validate-config validate-manifest help hook-impl"
  local global_opts="-h --help -V --version"

  # Function to recursively search for .pre-commit-config.yaml file
  _find_pre_commit_config() {
    local dir="$1"
    while [ "${dir}" != "/" ]; do
      if [ -f "${dir}/.pre-commit-config.yaml" ]; then
        echo "${dir}/.pre-commit-config.yaml"
        return 0
      fi
      dir=$(dirname "${dir}")
    done
    return 1
  }

  # Function to find hooks in configuration file
  _find_hooks() {
    local config_file
    config_file=$(_find_pre_commit_config "$(pwd)")
    [ $? -ne 0 ] && return 1

    local hooks
    if [ -n "${config_file}" ]; then
      hooks=$(grep -E '^\s+(-\s+)?(alias|id):\s+[^ ]+' "${config_file}" | sed -E 's/^\s+(-\s+)?\S+:\s+["\'"'"']?([^"'"'"' ]+)\s*$/\2/')
    else
      hooks=""
    fi
    echo "${hooks}"
  }

  case "${prev2}" in
    pre-commit)
      COMPREPLY=( $(compgen -W "${global_opts}" -- "${cur}") )
      return 0
      ;;
  esac


  local _cmd_arg cmd_arg
  for _cmd_arg in "${words[@]}"; do
    if [[ " ${commands} " == *" ${_cmd_arg} "* ]]; then
      # found a command
      cmd_arg=${_cmd_arg}
      break
    fi
  done

  # No command found yet, propose global options and commands
  if [ "$cmd_arg" == "" ] ; then
    COMPREPLY=( $(compgen -W "${global_opts} ${commands}" -- "${cur}") )
    return 0
  fi


  local autoupdate_options="--help --color -c --bleeding-edge --freeze -repo -j"
  local clean_options="--help"
  local gc_options="--help"
  local install_options="--help --hook-type"
  local install_hooks_options="--help"
  local migrate_config_options="--help"
  local run_options="--color --config --verbose --files --all-files --show-diff-on-failure --hook-stage --remote-branch --local-branch --from-ref --to-ref --pre-rebase-upstream --pre-rebase-branch --commit-msg-filename --prepare-commit-message-source --commit-object-name --remote-name --remote-url --checkout-type --is-squash-merge --rewrite-command --help"
  local sample_config_options="--help"
  local try_repo_options="--help"
  local uninstall_options="--help"
  local validate_config_options="--help"
  local validate_manifest_options="--help"
  local help_options="--help"
  local hook_impl_options="--help"

  local command_opts
  case "${cmd_arg}" in
    autoupdate)
      command_opts="${autoupdate_options}"
      ;;
    clean)
      command_opts="${clean_options}"
      ;;
    gc)
      command_opts="${gc_options}"
      ;;
    install)
      command_opts="${install_options}"
      ;;
    install-hooks)
      command_opts="${install_hooks_options}"
      ;;
    migrate-config)
      command_opts="${migrate_config_options}"
      ;;
    run)
      command_opts="${run_options}"
      ;;
    sample-config)
      command_opts="${sample_config_options}"
      ;;
    try-repo)
      command_opts="${try_repo_options}"
      ;;
    uninstall)
      command_opts="${uninstall_options}"
      ;;
    validate-config)
      command_opts="${validate_config_options}"
      ;;
    validate-manifest)
      command_opts="${validate_manifest_options}"
      ;;
    help)
      command_opts="${help_options}"
      ;;
    hook-impl)
      command_opts="${hook_impl_options}"
      ;;
    pre-commit)
      COMPREPLY=( $(compgen -W "${global_opts} ${commands}" -- "${cur}") )
      return 0
      ;;
  esac


  case "${cmd_arg}" in
    run)
      # Check for --files or hooks in the preceding arguments
      local hooks prev_arg exclude_git propose_files repo_files hooksError
      hooks=$(_find_hooks)
      hooksError=$?
      hooks_spaces=$(echo "$hooks" | tr '\n' ' ')
      propose_files=0
      exclude_git=()
      for prev_arg in "${words[@]}"; do

        [ "${prev_arg}" == "" ] && continue

        if [ "$propose_files" != "0" ] ; then
          exclude_git+=(":!${prev_arg}")

        elif [[ " ${hooks_spaces} " == *" ${prev_arg} "* ]]; then
          # "${prev_arg}" is in ${hooks}
          # Disable hook completion
          hooks=

        elif [[ "${prev_arg}" == "--files" ]]; then
          propose_files=1
        fi
      done

      if [ "$propose_files" != "0" ] ; then
        # Completion for files in the repository
        repo_files=$(git ls-files ":${cur}*" "${exclude_git[@]}" 2>/dev/null)
        COMPREPLY=( $(compgen -W "${repo_files}" -- "${cur}") )
        return 0
      fi

      if [ $hooksError -ne 0 ] ; then
        echo -e "\n\e[31mError: Possibly no .pre-commit-config.yaml\e[0m" >&2
        return 1
      fi
      COMPREPLY=( $(compgen -W "${command_opts} ${hooks}" -- "${cur}") )

      return 0
      ;;
    autoupdate|clean|gc|install|install-hooks|migrate-config|sample-config|try-repo|uninstall|validate-config|validate-manifest|help|hook-impl)
      COMPREPLY=( $(compgen -W "${command_opts}" -- "${cur}") )
      return 0
      ;;
    install|uninstall)
      local hooks
      hooks=$(_find_hooks)
      COMPREPLY=( $(compgen -W "${hooks}" -- "${cur}") )
      return 0
      ;;
  esac
}
complete -F _pre_commit_completion pre-commit
