#!/bin/bash
echo "Get max high sell value for first week of jan"
echo ""
curl -X POST http://127.0.0.1:8091/mapred -d @map-high.json
echo ""
echo ""
echo "Query that was run:"
cat map-high.json
echo ""
