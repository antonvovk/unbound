#!/bin/sh

unbound
doas munin-run unbound_munin_hits
tail -f /etc/unbound/unbound.log
