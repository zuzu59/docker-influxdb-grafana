#!/bin/bash
#Petit script pour nettoyer tout le binz
#zf191008.1551

#source: http://patatos.over-blog.com/2016/09/commet-faire-du-menage-dans-les-conteneurs-et-images-docker.html

echo -e "
Arrête le service et enlève le container ET aussi les datas
"

read -p "Etes-vous certain de vouloir tout effacer ?"
read -p "Mais cela va VRAIMENT VRAIMENT tout effacer, y compris les data !"

docker-compose down -v --remove-orphans

echo -e "
Suprime tous les volumes orphelins
"
docker volume ls
docker volume rm $(docker volume ls -qf dangling=true)
docker volume ls

echo -e "
Suprime tous les dossiers data
"
sudo rm -rf influxdb_data chronograf_data grafana_data




#echo -e "
#Suprime l'image
#"
#docker image ls
#docker image rm -f traefik:alpine
#docker image ls


