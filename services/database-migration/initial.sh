#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

echo "GRAPHILE_PASSWORD=$GRAPHILE_PASSWORD"

psql -c "create role graphile with login password '$GRAPHILE_PASSWORD'"