#!/bin/bash
#Petit script pour enregistrer des durées d'exécution de scripts dans InfluxDB
#zf191008.1032


echo "start...."
t1=$(date +%s%N)
sleep 1
t2=$(date +%s%N)
echo "stop..."

t21=$(echo "($t2 - $t1)/1000000" | bc -l)




echo -e "

Le script a commencé à $(date -d @$(echo "$t1/1000000000" |bc -l))

Il a termniné à $(date -d @$(echo "$t2/1000000000" |bc -l))


Et a duré $t21 secondes

"

exit




p=$(echo "1 + $RANDOM % 10" | bc)
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "energy,compteur=2 puissance=$p"
sleep 3



