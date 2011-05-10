#!/bin/bash
echo "Find days where the close is lower than the open"
echo ""
curl -X POST http://127.0.0.1:8091/mapred -d @sample-close-lt-open.json
echo ""
echo ""
echo "Query that was run:"
cat sample-close-lt-open.json
echo ""
