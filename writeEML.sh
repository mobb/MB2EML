#!/bin/bash

# sbc_metabase
# OK: 99021 99024
# Not OK: 99013

# mcr_metabase
# OK:
# Not OK: 99001 99002 99016 99602
# 99001 99002 99016 996002

export databaseName='sbc_metabase'
export datasetId='99013'
export validate=1	# a value lf '1' indicates true - run with validation
export runEMLParser=1	# a value lf '1' indicates true - run the EML Parser
export verbose=1	# a value lf '1' indicates true - run in verbose mode

./writeEML.pl $databaseName $datasetId $validate $runEMLParser $verbose
