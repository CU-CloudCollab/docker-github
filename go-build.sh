#!/bin/bash

# Build the Docker image

# Touch the version file so that Docker will think source has changed.
date > version

docker build --tag example .