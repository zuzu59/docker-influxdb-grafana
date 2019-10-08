#!/bin/bash
#Petit script pour enregistrer des durées d'exécution de scripts dans InfluxDB
#zf191008.1119


echo "start...."
t1=$(date +%s%N)
sleep 1.5
t2=$(date +%s%N)
echo "stop..."

t21=$(echo "($t2 - $t1)/1000000000" | bc -l)


echo "start envoi..."
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "scripts,test=test1 state_z=1 $t1"
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "scripts,test=test1 state_z=1 $t2"
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "scripts,test=test1 time_duration=$t21"
echo "stop envoi..."



echo -e "

Le script a commencé à $(date -d @$(echo "$t1/1000000000" |bc -l))

Il a termniné à $(date -d @$(echo "$t2/1000000000" |bc -l))


Et a duré $t21 secondes

"

exit




p=$(echo "1 + $RANDOM % 10" | bc)
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "energy,compteur=2 puissance=$p"
sleep 3



