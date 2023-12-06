#!/bin/sh

doas nginx
doas unbound
doas -u munin munin-node --debug --pidebug
doas crond -l 8 -d 8 -L /var/log/crond.log

tail -f /var/log/unbound.log
