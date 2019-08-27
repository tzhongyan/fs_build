#!/bin/bash
docker run -d -v --name fs $(pwd)/conf/:/usr/local/freeswitch/conf/ -v $(pwd)/tmp:/tmp freeswitch:mods