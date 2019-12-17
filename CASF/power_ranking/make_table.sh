

for selector in rmr5 rmr6 rmsd
do
	for ranker in rmc10 rmc11 rmc12 rmc13 rmc14 rmc15 fmc10 fmc11 fmc12 fmc13 fmc14 fmc15
	do
		echo -n "$selector,$ranker,"
		grep 't1\*' ${selector}_${ranker}_Spearman-ci.results | awk '{printf $2}'
		echo -n ","
		grep '90%' ${selector}_${ranker}_Spearman-ci.results | awk '{print $3 $4}'
	done
done
