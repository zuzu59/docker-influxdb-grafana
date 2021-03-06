#!/bin/bash
#Petit script pour démarrer tout le binz
#zf191008.1640, zf210102.1449
#pour installer Docker et Docker compose sur une machine Ubuntu c'est ici:
#https://github.com/zuzu59/docker_demo

mkdir influxdb_data chronograf_data grafana_data
chmod -R 777 influxdb_data chronograf_data grafana_data

#docker-compose up
docker-compose up -d
docker-compose logs -f


echo -e "

pour voir les logs en continu:
docker-compose logs -f

pour voir qu'est-ce qui tourne:
docker-compose ps

pour 'entrer' dans un 'service':
docker-compose exec nom_service /bin/bash
docker-compose exec influxdb /bin/bash
docker-compose exec grafana /bin/bash

pour arrêter:
docker-compose stop

pour redémarrer après un 'stop':
docker-compose start

pour enlever les container mais pas les datas:
docker-compose down

pour enlever les container ET aussi les datas:
docker-compose down -v --remove-orphans



ATTENTION:
N'oubliez pas RAPIDEMENT d'aller changer le password par défault (admin) du compte admin de Grafana !

Et... de faire tourner une seule fois le script: './configure_influxdb.sh' afin de configurer le compte admin de InfluxDB !


"


