#!/bin/bash
# test_pre_commit_completion.sh
# shellcheck disable=all  #disabled for now


# Source the completion script for testing
source "$(realpath "$(dirname "$0")/../pre-commit-completion.bash")"

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
    echo "${COMPREPLY[@]}"
    assert_equals "Expected completion for hook names" "some-hook" "${COMPREPLY[0]}"

    # Test completion after "pre-commit run --"
    COMP_WORDS=("pre-commit" "run" "--")
    COMP_CWORD=3
    _pre_commit_completion
    assert_matches "Expected run options completion" "${COMPREPLY[*]}" "--color"
    assert_matches "Expected run options completion" "${COMPREPLY[*]}" "--config"
    # Add more assertions for other run options
}

test_pre_commit_global_options_completion() {
    # Test completion for global options
    COMP_WORDS=("pre-commit")
    COMP_CWORD=1
    _pre_commit_completion
    assert_matches "Expected global options completion" "${COMPREPLY[*]}" "-h"
    assert_matches "Expected global options completion" "${COMPREPLY[*]}" "--help"
    # Add more assertions for other global options
}
