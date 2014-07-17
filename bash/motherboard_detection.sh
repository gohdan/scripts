#!/bin/sh
dd if=/dev/mem bs=64k skip=15 count=1|strings|less
