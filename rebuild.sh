#!/bin/bash
docker kill fs
docker rm fs
docker build -t freeswitch:mods .