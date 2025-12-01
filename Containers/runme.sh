#!/bin/bash
rtl_433 -v -f 914900000 -C customary -F mqtt://<server>:<port>,user=<username>,pass=<password>,retain=0,devices=sensors[/type][/model][/subtype][/channel:0][/id]
