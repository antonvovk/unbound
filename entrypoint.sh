#!/bin/sh

doas unbound
tail -f /var/log/unbound/unbound.log
