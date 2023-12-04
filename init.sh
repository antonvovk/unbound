#!/bin/sh

doas -u unbound unbound
doas munin-node --debug --pidebug
doas -u munin munin-cron --debug
tail -f /var/log/unbound/unbound.log
