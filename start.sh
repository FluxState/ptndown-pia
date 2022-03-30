#!/bin/bash

service cron start

bash /run.sh

tail -f /dev/null
