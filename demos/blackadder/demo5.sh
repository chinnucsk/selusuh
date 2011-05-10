#!/bin/bash
echo "Get the entries of the fears of the underlings of blackadder's underlings"
echo ""
curl -v -X GET http://127.0.0.1:8091/riak/soldiers/blackadder/_,underling,0/_,underling,0/_,fear,0/wit,entry,1/
echo ""
