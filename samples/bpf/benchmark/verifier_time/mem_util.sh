#!/bin/bash

# Just keep checking meminfo repeatedly.

old_amt=`free -b | sed -n 2p | xargs | cut -d' ' -f 3`
former_amt=$old_amt
new_amt=$old_amt

while kill -0 $1 2> /dev/null; do
	curr_state=`cat /proc/$1/stat | cut -d' ' -f 3`
	if [ "$curr_state" = "R" ]; then
		former_amt=$new_amt
		new_amt=`free -b | sed -n 2p | xargs | cut -d' ' -f 3`
		sleep 0.1
	fi
done
echo "$former_amt"
echo "$old_amt"
echo "$(( $former_amt - $old_amt ))"
echo "$(( $former_amt - $old_amt ))" >> memory.tmp
