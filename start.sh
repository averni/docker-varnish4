#! /bin/sh
#
# start.sh
# Copyright (C) 2015 antonio <me.verni@gmail.com>
#
# Distributed under terms of the MIT license.
#

/etc/init.d/munin-node start

varnishd -F -u varnish \
  -f $VCL_CONFIG \
  -s malloc,$CACHE_SIZE \
  $VARNISHD_PARAMS
