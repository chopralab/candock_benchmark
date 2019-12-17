

for sf in rmr5 rmr6
do
	for type in pure mixed
	do
		for top in Top1 Top2 Top3
		do
	                echo -n "$sf,$type,$top,"
	                grep 't1\*' ${sf}_${type}_${top}-ci.results | awk '{printf $2}'
        	        echo -n ","
                	grep '90%' ${sf}_${type}_${top}-ci.results | awk '{print $3 $4}'

		done
	done
done
