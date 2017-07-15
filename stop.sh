#!/bin/sh
echo "WE'RE ABOUT TO STOP RIGHT NOW !"
# seal vault
ps | grep "vault server" | awk '{print $1}' | head -1 | xargs kill
echo "Everything is properly stopped, we can exit"
rm -f /tmp/letitrun
