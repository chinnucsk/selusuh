#!/bin/bash
echo "Simply echo all the values that we find"
echo ""
curl -X POST http://127.0.0.1:8091/mapred -d @simple-map.json
echo ""
echo ""
echo "Query that was run:"
cat simple-map.json
echo ""
