#!/bin/bash
# Build the image and start a Postgres container, then drop into psql.
# Edit init.sql with your CREATE DATABASE / CREATE TABLE / INSERT statements
# first, then re-run this script.

docker build -t blueapron_db .
docker run --name pg_blueapron --rm -e POSTGRES_PASSWORD=password -d blueapron_db
sleep 3 # give postgres time to get ready
# Land in the blueapron database if your init.sql has created it; until then,
# fall back to the default postgres database (run `\c blueapron` after you
# create it, or your tables will end up in the wrong database).
docker exec -it pg_blueapron psql -h localhost -p 5432 -U postgres -d blueapron || \
  docker exec -it pg_blueapron psql -h localhost -p 5432 -U postgres
