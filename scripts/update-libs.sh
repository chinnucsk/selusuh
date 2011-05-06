#!/bin/bash

SCRIPTDIR=`dirname $0`
JSDIR=$SCRIPTDIR/../js
JQUERYVER=1.4.2

mkdir -p $JSDIR
cd $JSDIR
echo "Downloading json2.js ..."
curl -O https://github.com/basho/riak-javascript-client/raw/master/json2.js
echo "Downloading riak.js ..."
curl -O https://github.com/basho/riak-javascript-client/raw/master/riak.js
echo "Downloading jquery.min.js ..."
curl http://code.jquery.com/jquery-$JQUERYVER.min.js > jquery.min.js
echo "Download jQuery jquery.tmpl.min.js ..."
curl -O http://ajax.aspnetcdn.com/ajax/jquery.templates/beta1/jquery.tmpl.min.js
echo "Downloadling modernizr.min.js ..."
curl -X POST http://www.modernizr.com/downloadjs/ -d "" > modernizr.min.js

echo "Finished updating libraries."
