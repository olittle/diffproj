for v in $(eval echo {$1..$2})
do
	echo $v
	nohup python main-threshold.py $v > nohup.$v & 
done 
