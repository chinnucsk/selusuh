#!/bin/bash
echo "Collect the max high sells per month"
echo ""
curl -X POST http://127.0.0.1:8091/mapred -d @map-highs-by-month.json
echo ""
echo ""
echo "Query that was run:"
cat map-highs-by-month.json
echo ""
