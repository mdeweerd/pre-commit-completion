#!/bin/bash

# Record help information to detect changes

{
    echo "########### PRE-COMMIT"
    pre-commit run -h

    for cmd in autoupdate clean gc init-templatedir install install-hooks migrate-config run sample-config try-repo uninstall validate-config validate-manifest help hook-impl ; do
        echo "########### $cmd"
        pre-commit help $cmd
    done
} |& tee "$(dirname "$0")/help.log"
