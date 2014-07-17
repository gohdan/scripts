#!/bin/sh
j=1; for i in `ls`; do mv $i 'tpl_'$j'.jpg'; let "j += 1"; done
