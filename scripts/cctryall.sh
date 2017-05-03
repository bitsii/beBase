#!/bin/bash

./scripts/cctrycl.sh

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

./scripts/cctrygn.sh

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
