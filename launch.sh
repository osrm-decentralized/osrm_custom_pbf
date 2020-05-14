#!/bin/bash

# 14.5.2020
# OSRM using pre-made .pbf's from https://server.nikhilvj.co.in/dump/ or other source

# bring in environment variables
# var=${DEPLOY_ENV:-default_value} - from https://stackoverflow.com/a/39296572/4355695
OSMPBF=${PBFURL:-https://server.nikhilvj.co.in/dump/chennai.pbf}

profile=${PROFILE:-/profiles/car-modified.lua}


# downloading OSM data from URL. Saves as area.pbf for simplicity in later commands.
wget -N --timeout=20 -O /data/area.pbf ${OSMPBF}


# compiling commands of OSRM - builds the graph
osrm-extract -p ${profile} /data/area.pbf
osrm-partition /data/area.osrm
osrm-customize /data/area.osrm


# list all files created in compile
ls -lS /data/


# setting env variable DISABLE_ACCESS_LOGGING=1 for improving performance
DISABLE_ACCESS_LOGGING=1
export DISABLE_ACCESS_LOGGING


# launch OSRM-backend API
osrm-routed --algorithm mld /data/area.osrm
