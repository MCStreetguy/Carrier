#!/bin/execlineb -S0

if { chmod 0755 /bin/* }
if { chmod 0755 /usr/bin/* }
if { chmod 0755 /usr/local/bin/* }
if { chmod 0740 /sbin/* }
if { chmod 0740 /usr/sbin/* }

exit 0