#!/bin/sh

doas -u unbound unbound
doas munin-node
tail -f /var/log/unbound/unbound.log
