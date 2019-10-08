#!/bin/bash
#Petit script pour tester l'enregistrement des durées d'exécution de scripts dans InfluxDB
#zf191008.1506


echo "start...test_batch_script"



for i in {1..5}
do
    ./test_record_script.sh test$i 0 $(echo "5*$RANDOM/32767" | bc -l) &
done

sleep 6

for i in {1..5}
do
    ./test_record_script.sh test$i 1.0 $(echo "5*$RANDOM/32767" | bc -l) &
done




echo "stop...test_batch_script"


