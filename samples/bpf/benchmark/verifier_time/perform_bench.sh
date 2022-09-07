#!/bin/bash

echo '==================== BENCHMARK STARTED ===================='
echo 'Targeting all the  minimal* files in the current directory'
echo ''
echo 'Results will be in results-[date].csv upon finishing'

minimals=`ls ./minimal*`
fn_date=`date +"%Y%m%d-%H%M"`
filename="results-$fn_date.csv"

echo -n "binary" >> $filename
echo -n "," >> $filename
echo -n "time" >> $filename
echo -n "," >> $filename
echo -n "insn" >> $filename
echo "," >> $filename

for minimal in $minimals
do
	./$minimal > /dev/null 2> /dev/null
	t_record=`journalctl -k -n 6 | sed -n 2,2p | cut -d':' -f 5`
	i_record=`journalctl -k -n 6 | sed -n 3,3p | cut -d':' -f 5`
	#echo "t_record is:$t_record"
	#echo "i_record is:$i_record"
	echo -n "$minimal" >> $filename
	echo -n "," >> $filename
	echo -n "$t_record" >> $filename
	echo -n "," >> $filename
	echo -n "$i_record" >> $filename
	echo "," >> $filename
done
