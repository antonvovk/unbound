#!/bin/sh

doas -u nginx nginx
doas -u unbound unbound
doas munin-node --debug --pidebug
doas crond -l 8 -d 8 -L /var/log/crond.log
tail -f /var/log/unbound.log
