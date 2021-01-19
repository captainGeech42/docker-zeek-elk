#!/bin/sh

# filebeat requires only owner to have write perms on config file
chmod go-w filebeat/zeek.yml

# build
docker-compose build

# run
docker-compose up -d
