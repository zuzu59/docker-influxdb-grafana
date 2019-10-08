#!/bin/bash
#Petit script pour enregistrer des durées d'exécution de scripts dans InfluxDB
#zf191008.1508

#test si l'argument est vide
if [ -z "$1" ]
  then
    echo -e "\nUsage: ./test_record_script.sh state_val nom_du_test durée_du_test \n\n"
    exit
fi

#sleep $(echo "5*$RANDOM/32767" | bc -l)

echo "start....$1"
t1=$(date +%s%N)
sleep $3
t2=$(date +%s%N)
#echo "stop...$1"

t21=$(echo "($t2 - $t1)/1000000000" | bc -l)


#echo "start envoi..."
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "scripts,test=$1 state_z=$2 $t1" &
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "scripts,test=$1 state_z=$(echo "$2+1" |bc -l) $t2" &
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "scripts,test=$1 time_duration=$t21" &
#echo "stop envoi..."



echo -e "

Le script $1 a commencé à $(date -d @$(echo "$t1/1000000000" |bc -l))

Il a termniné à $(date -d @$(echo "$t2/1000000000" |bc -l))


Et a duré $t21 secondes

"

exit




p=$(echo "1 + $RANDOM % 10" | bc)
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "energy,compteur=2 puissance=$p"
sleep 3



