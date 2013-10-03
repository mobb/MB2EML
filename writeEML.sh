#!/bin/bash

databaseName=$1
datasetId=$2

if [ "$databaseName" == "" ]; then
    databaseName='mcr_metabase'
fi

if [ "$datasetId" == "" ]; then
    datasetId=2
fi

if [ ! -e out ]; then
    mkdir out
fi

./writeEML.pl -pvx -d out $databaseName $datasetId
