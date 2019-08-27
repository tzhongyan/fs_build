#!/bin/bash
docker create --name fs -v $(pwd)/conf/:/usr/local/freeswitch/conf/ -v $(pwd)/tmp:/tmp freeswitch:mods
