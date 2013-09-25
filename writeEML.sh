#!/bin/bash

databaseName='mcr_metabase'
datasetId='10'
validate=1	# a value lf '1' indicates true - run with validation
runEMLParser=1	# a value lf '1' indicates true - run the EML Parser
verbose=1	# a value lf '1' indicates true - run in verbose mode

./writeEML.pl $databaseName $datasetId $validate $runEMLParser $verbose
