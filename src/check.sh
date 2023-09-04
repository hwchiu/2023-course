#!/bin/sh
curl -s localhost:5000/health | jq -e 'select(.message=="Hello, Docker!")'
