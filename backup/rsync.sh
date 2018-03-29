#!/bin/sh
rsync -avx /src/ /dst/live/ --backup --backup-dir=/dst/shadows/$(date +%Y%m%dT%H%M%S)/
