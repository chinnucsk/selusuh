#!/bin/bash
echo "Get blackadder's underlings"
echo ""
curl -v -X GET http://127.0.0.1:8091/riak/soldiers/blackadder/_,underling,1/
echo ""
