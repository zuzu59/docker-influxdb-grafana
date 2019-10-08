#!/bin/bash
#Petit script pour configurer la DB InfluxDB
#zf191008.1554

echo "Start..."

### Création d'un compte administrateur
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query" --data-urlencode "q=CREATE USER $dbflux_u_admin WITH PASSWORD '$dbflux_p_admin' WITH ALL PRIVILEGES"


### Création d'une base de données
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=CREATE DATABASE $dbflux_db"


### Création d'un Utilisateur
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=CREATE USER $dbflux_u_user WITH PASSWORD '$dbflux_p_user'"


### Attribution d'une base de données à un utilisateur
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=GRANT ALL ON $dbflux_db TO $dbflux_u_user"


echo "Configuration de InfluxDB terminée"



