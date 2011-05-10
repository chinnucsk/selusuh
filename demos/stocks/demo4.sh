#!/bin/bash
echo "Find days where the high was over $600"
echo ""
curl -X POST http://127.0.0.1:8091/mapred -d @sample-highs-over-600.json
echo ""
echo ""
echo "Query that was run:"
cat sample-highs-over-600.json
echo ""
