#!/bin/bash
# Build the image and start a Postgres container, then drop into psql.
# Edit init.sql with your CREATE DATABASE / CREATE TABLE / INSERT statements
# first, then re-run this script.

docker build -t blueapron_db .
docker run --name pg_db --rm -e POSTGRES_PASSWORD=password -d blueapron_db
sleep 3 # give postgres time to get ready
docker exec -it pg_db psql -h localhost -p 5432 -U postgres
