#!/bin/sh -xe

export ENVIRONMENT = 'production'
sh build.sh
sh release.sh