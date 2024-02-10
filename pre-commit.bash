# pre-commit bash-completion script
# Source https://github.com/mdeweerd/pre-commit-completion
# shellcheck shell=bash
# shellcheck disable=2207,2181

_pre_commit_completion() {
    # shellcheck disable=2034
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
        local config_file hooks quotes
        config_file=$(_find_pre_commit_config "$(pwd)")
        [ $? -ne 0 ] && return 1

        if [ -n "${config_file}" ]; then
            quotes="\"'"  # To avoid beautysh incompatibility
            hooks=$(grep -E '^\s+(-\s+)?(alias|id):\s+[^ ]+' "${config_file}" | sed -E 's/^\s+(-\s+)?\S+:\s+'"[$quotes]?([^$quotes: ]+)"'/\2/')
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


    local color_options="auto always never"
    local stages="commit-msg post-checkout post-commit post-merge post-rewrite pre-commit pre-merge-commit pre-push pre-rebase prepare-commit-msg manual"
    local options
    case "${prev}" in
        --color)
            options="${color_options}"
            ;;
        --config|-c)
            config_files=$(git ls-files ":${cur}*" 2>/dev/null)
            options="${config_files}"
            ;;
        -t|--hook-type|--hook-stage)
            options="${stages}"
            ;;
        --remote-branch)
            options="$(git branch -r --format "%(refname:lstrip=2)")"
            ;;
        --local-branch)
            options="$(git branch -l --format "%(refname:lstrip=2)")"
            ;;
        --ref|--from-ref|--source|-s|--to-ref|--origin|-o)
            # User must provide option
            return 0
            ;;
        --pre-rebase-upstream)
            options="$(git remote)"
            ;;
        --pre-rebase-branch)
            options="$(git branch -l --format "%(refname:lstrip=2)")"
            ;;
        --hook-dir)
            COMPREPLY=( $(compgen -d -- "${cur}") )
            return 0
            ;;
        --commit-msg-filename)
            COMPREPLY=( $(compgen -f -- "${cur}") )
            return 0
            ;;
        --commit-object-name)
            return 0
            ;;
        --remote-name|--remote-url)
            return 0
            ;;
        --checkout-type|--is-squash-merge)
            options="0 1"
            ;;
        --rewrite-command)
            return 0
            ;;
    esac

    if [ "${options}" != "" ] ; then
        COMPREPLY=( $(compgen -W "${options}" -- "${cur}") )
        return 0
    fi

    local autoupdate_options="--help --color -c --bleeding-edge --freeze -repo -j"
    local clean_options="--help --color"
    local gc_options="--help --color"
    local install_options="--help --hook-type --color -c --config -f --overwrite --install-hooks --allow-missing-config -t --hook-type"
    local install_hooks_options="--help --color -c --config"
    local migrate_config_options="--help --color -c --config"
    local run_options="--color --config -v --verbose --files -a --all-files --show-diff-on-failure --hook-stage --remote-branch --local-branch --from-ref --to-ref --pre-rebase-upstream --pre-rebase-branch --commit-msg-filename --prepare-commit-message-source --commit-object-name --remote-name --remote-url --checkout-type --is-squash-merge --rewrite-command --help"
    local sample_config_options="--help --color"
    local try_repo_options="--ref --color --config --verbose --files --all-files --show-diff-on-failure --hook-stage --remote-branch --local-branch --from-ref --to-ref --pre-rebase-upstream --pre-rebase-branch --commit-msg-filename --prepare-commit-message-source --commit-object-name --remote-name --remote-url --checkout-type --is-squash-merge --rewrite-command --help"
    local uninstall_options="--help --color -c --config -t --hook-type"
    local validate_config_options="--help --color"
    local validate_manifest_options="--help --color"
    local help_options="--help $commands"
    local hook_impl_options="--help --color -c --config --hook-type --hook-dir --skip-on-missing-config"


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
        try-repo|run)
            # Check for --files or hooks in the preceding arguments
            local hooks prev_arg exclude_git propose_files repo_files hooksError has_repo
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
                elif [[ "${prev_arg}" == *":"* ]] || [[ -r "${prev_arg}"/.pre-commit-hooks.yaml ]] ; then
                    # Might be a link, suppose repo is provided
                    has_repo=1
                fi
            done

            if [ "$propose_files" != "0" ] ; then
                # Completion for files in the repository
                repo_files=$(git ls-files ":${cur}*" "${exclude_git[@]}" 2>/dev/null)
                COMPREPLY=( $(compgen -W "${repo_files}" -- "${cur}") )
                return 0
            fi

            if [ "${cmd_arg}" == "try-repo" ] && [ "${has_repo}" != "1" ] ; then
                # Completion for directories (try-repo is likely local)
                COMPREPLY=( $(compgen -d -- "${cur}") )
                if [ ! -r "${cur}/.pre-commit-hooks.yaml" ]; then
                    COMPREPLY=( $(compgen -d -- "${cur}") )
                fi
                return 0
            fi

            if [ $hooksError -ne 0 ] ; then
                echo -e "\n\e[31mError: Possibly no .pre-commit-config.yaml\e[0m" >&2
                return 1
            fi
            COMPREPLY=( $(compgen -W "${command_opts} ${hooks}" -- "${cur}") )

            return 0
            ;;
        autoupdate|clean|gc|migrate-config|sample-config|help|hook-impl)
            COMPREPLY=( $(compgen -W "${command_opts}" -- "${cur}") )
            return 0
            ;;
        install|uninstall)
            local hooks
            hooks=$(_find_hooks)
            COMPREPLY=( $(compgen -W "${hooks}" -- "${cur}") )
            return 0
            ;;
        validate-config|validate-manifest)
            local options_filtered=""
            local _args=" ${words[*]} "
            for o in $command_opts ; do
                if [[ "$_args" != *" $o "* ]] ; then
                    options_filtered="$options_filtered $o"
                fi
            done
            # Generate filenames
            COMPREPLY=( $(compgen -f -- "${cur}") )
            COMPREPLY+=( $(compgen -W "$options_filtered" -- "${cur}") )  # add options
            return 0
            ;;
    esac
}

function _pre_commit_comma_list() {
    # Allow building list of options with separator (provided to attempt SKIP completion)
    local cur sep list

    cur="$1" ; shift
    sep="$1" ; shift
    list=("$@")

    sep=${sep:=,}  # Default separator

    if [[ "$cur" == *"${sep}"* ]]; then
        # Already has an element

        # for internals
        local lastitem prefix chosen remaining

        lastitem="${cur##*"${sep}"}"
        prefix="${cur%"${sep}"*}"
        chosen=()
        IFS="${sep}" read -ra chosen <<< "$prefix"

        remaining=()

        readarray -t remaining <<< "$(printf '%s\n' "${list[@]}" "${chosen[@]}" | sort | uniq -u)"

        if [[ ${#remaining[@]} -gt 0 ]]; then
            readarray -t COMPREPLY <<< "$(compgen -W "${remaining[*]}" -P "${prefix}${sep}" -- "$lastitem")"
            #echo "\n'$cur' HERE ${list[@]} COMP ${COMPREPLY[@]} ENDHERE\n"

            # add separator if user tabs again after entering a complete name
            if [ "$lastitem" != '' ] && [[ ${#COMPREPLY[@]} -eq 1 ]] && [ "${prefix}${sep}$lastitem" == "${COMPREPLY[0]}" ]; then
                # Exactly one remaining match corresponding to our last item
                COMPREPLY=("${COMPREPLY[0]}${sep}")
            fi

            if [[ ${#remaining[@]} -gt 1 ]]; then
                compopt -o nospace
            fi
        fi
    else
        # First item
        #COMPREPLY=($(compgen -W "${list[*]}" -- "$cur"))
        readarray -t COMPREPLY <<< "$(compgen -W "${list[*]}" -- "$cur")"
        if [ "$cur" != "" ] && [[ ${#COMPREPLY[@]} -eq 1 ]] && [ "$cur" = "${COMPREPLY[0]}" ]; then
            # Exactly one remaining match corresponding to our last item
            COMPREPLY=("${COMPREPLY[0]}${sep}")
        fi
        compopt -o nospace
    fi
}

if [ "0" == "$TERM" ] ; then
    # Example usage with dummy command and abc,def,ghf options
    function _dummy_bash() {
        # shellcheck disable=2034
        local cur prev words cword

        _init_completion || return

        option_list=("abc" "def" "ghf")
        _pre_commit_comma_list "${cur}" "," "${option_list[@]}"
    }
    complete -F _dummy_bash dummy
fi


# Define a completion function for the SKIP environment variable
_SKIP_completion() {
    # work in progress

    # shellcheck disable=2034
    local cur prev words cword

    _init_completion || return

    # Get the list of hooks from the configuration file
    local hooks
    local IFS=$' \t\n'

    hooks=$(_find_hooks)
    #readarray -t hooks <<< "$(compgen -W "$(_find_hooks)" -- "")"
    hooks=($(compgen -W "$(_find_hooks)" -- ""))
    # for i in "${hooks[@]}" ; do echo ":$i:" ; done
    _pre_commit_comma_list "${cur}" "," "${hooks[@]}"
}

# Set up completion for the SKIP environment variable (not functional)
# Currently matches SKIP<SPACE><TAB> - Should match SKIP=<TAB>
complete -F _SKIP_completion "SKIP"
complete -F _pre_commit_completion pre-commit
