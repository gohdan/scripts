#!/bin/sh
find /proc -name fd -type d -exec sh -c "echo \`ls {}|wc -l\` {}" \;|sort -n -r|head

