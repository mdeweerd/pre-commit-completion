#!/bin/bash
#
if [ ! -r ./bash_unit ] ; then
    # https://github.com/pgrange/bash_unit.git
    bash <(curl -s https://raw.githubusercontent.com/pgrange/bash_unit/master/install.sh)
fi

./bash_unit tests/test_pre_commit_completion.sh
