nohup python HINCascade.py all > all.result.summary &
wait
nohup python HINCascade.py pool > pool.result.summary &

wait 

nohup ./../logisiticregression-noise/task.bash & 
