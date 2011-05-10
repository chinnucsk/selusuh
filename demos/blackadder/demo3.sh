#!/bin/bash
echo "Get blackadder's equipment"
echo ""
curl -v -X GET http://127.0.0.1:8091/riak/soldiers/blackadder/_,wit,1/
echo ""

