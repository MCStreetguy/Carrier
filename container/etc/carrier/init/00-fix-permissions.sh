#!/bin/execlineb -S0

if { s6-echo "[carrier-init] fixing general filesystem permissions..." }
if { elglob FILES /bin/* chmod 0755 ${FILES} }
if { elglob FILES /usr/bin/* chmod 0755 ${FILES} }
if { elglob FILES /sbin/* chmod 0740 ${FILES} }
if { elglob FILES /usr/sbin/* chmod 0740 ${FILES} }

exit 0