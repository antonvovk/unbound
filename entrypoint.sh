#!/bin/sh

doas -u unbound unbound
tail -f /var/log/unbound/unbound.log
