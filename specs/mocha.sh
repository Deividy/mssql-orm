#!/bin/bash

SPECS=`dirname $0`
MOCHA=$SPECS/../node_modules/mocha/bin/mocha
echo $MOCHA

$MOCHA --reporter spec --require should --compilers coffee:coffee-script $SPECS/$1
