#!/bin/bash

if [ -t 0 ]; then
  TERM_OPT='-t'
fi

docker run --rm -i $TERM_OPT --link some-postgres:postgres -e PGPASSWORD=postgres postgres:9.6 psql -h postgres -U postgres
