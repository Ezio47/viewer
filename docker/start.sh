#!/bin/bash


docker run -d -p 80:80 --name='rialto.dev' -restart=always radiantblue/tuple-rialto:latest
Put quickstart shell commands here that start the tuple viewer and
tuple wps containers, and link them with proper networking etc.

