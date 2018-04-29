#!/bin/bash
docker run -p 5432:5432 --name some-postgres -e POSTGRES_PASSWORD=postgres -d postgres:9.6
