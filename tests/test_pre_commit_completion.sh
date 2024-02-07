#!/bin/bash
# test_pre_commit_completion.sh
# shellcheck disable=2034,1090


# Source the completion script for testing
# # shellcheck source=../pre-commit.bash
source "$(realpath "$(dirname "$0")/../pre-commit.bash")"

_init_completion() {
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword="${COMP_CWORD}"
}

test_pre_commit_run_completion() {
    # Test completion after "pre-commit run"
    COMP_WORDS=("pre-commit" "run" "beautysh")
    COMP_CWORD=3
    _pre_commit_completion
    #echo "${COMPREPLY[@]}"
    assert_equals "--color --config -v --verbose --files -a --all-files --show-diff-on-failure --hook-stage --remote-branch --local-branch --from-ref --to-ref --pre-rebase-upstream --pre-rebase-branch --commit-msg-filename --prepare-commit-message-source --commit-object-name --remote-name --remote-url --checkout-type --is-squash-merge --rewrite-command --help" "${COMPREPLY[*]}" "TEST1"

    # Test completion after "pre-commit run --"
    COMP_WORDS=("pre-commit" "run" "--")
    COMP_CWORD=3
    _pre_commit_completion
    assert_matches "--color --config -v --verbose --files -a --all-files --show-diff-on-failure --hook-stage --remote-branch --local-branch --from-ref --to-ref --pre-rebase-upstream --pre-rebase-branch --commit-msg-filename --prepare-commit-message-source --commit-object-name --remote-name --remote-url --checkout-type --is-squash-merge --rewrite-command --help no-commit-to-branch check-yaml check-json mixed-line-ending trailing-whitespace end-of-file-fixer check-merge-conflict check-executables-have-shebangs check-shebang-scripts-are-executable fix-byte-order-marker check-case-conflict beautysh local-precommit-script prettier yamllint codespell shellcheck tests" "${COMPREPLY[*]}" "TEST2"
    # Add more assertions for other run options
}

test_pre_commit_global_options_completion() {
    # Test completion for global options
    COMP_WORDS=("pre-commit")
    COMP_CWORD=1
    _pre_commit_completion
    assert_matches "-h --help -V --version autoupdate clean gc init-templatedir install install-hooks migrate-config run sample-config try-repo uninstall validate-config validate-manifest help hook-impl" "${COMPREPLY[*]}" "-h"
    # Add more assertions for other global options
}
