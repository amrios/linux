#!/bin/bash

echo '==================== BENCHMARK STARTED ===================='
echo 'Targeting all the  minimal* files in the current directory'
echo ''
echo 'Results will be in results-[date].csv upon finishing'

minimals=`ls ./minimal*`
fn_date=`date +"%Y%m%d-%H%M"`
filename="results-$fn_date.csv"
minimal="./minimal2000000"

echo -n "binary" >> $filename
echo -n "," >> $filename
echo -n "time" >> $filename
echo -n "," >> $filename
echo -n "insn" >> $filename
echo "," >> $filename

pid=`./$minimal > /dev/null 2> /dev/null & echo $!`
./mem_util.sh $pid
#tail --pid=$pid -f /dev/null
t_record=`journalctl -k -n 6 | sed -n 2,2p | cut -d':' -f 5`
i_record=`journalctl -k -n 6 | sed -n 3,3p | cut -d':' -f 5`
	# Wait until analyzer outputs a file...	

while [ ! -f ./memory.tmp ]
do
	sleep 0.5
done
	m_record=`tail -n 1 ./memory.tmp`

#echo "t_record is:$t_record"
#echo "i_record is:$i_record"
echo -n "$minimal" >> $filename
echo -n "," >> $filename
echo -n "$t_record" >> $filename
echo -n "," >> $filename
echo -n "$i_record" >> $filename
echo -n "," >> $filename
echo -n "$m_record" >> $filename
echo "," >> $filename
rm ./memory.tmp
sleep 1
