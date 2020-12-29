Comment purger des séries sur Influxdb de manière sélective ?

zf201230.0036

Après un certain temps de fonctionnement de manière intensive d'InfluxDB, on peut très facilement avoir des dizaines de millions d'enregistrements dans InfluxDB, ce qui conduit inexorablement à la saturation du disque de données sur le serveur InfluxDB.

Le moment est venu alors de purger les enregistrements inutiles de manière très sélective.

L'avantage de InfluxDB, c'est que l'on peut tout gérer via des requêtes CURL, donc il suffit juste de savoir quelle requête CURL utiliser pour bien gérer InfluxDB.

<!-- TOC titleSize:2 tabSpaces:2 depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 skip:0 title:1 charForUnorderedList:* -->
## Table of Contents
* [Astuces](#astuces)
  * [Partage des secrets dans ce petit manuel !](#partage-des-secrets-dans-ce-petit-manuel-)
  * [Utilisation de Chronograf pour *explorer* Influxdb](#utilisation-de-chronograf-pour-explorer-influxdb)
* [Structure des données dans Influxdb](#structure-des-données-dans-influxdb)
* [Le nom de la base de données](#le-nom-de-la-base-de-données)
  * [Afficher les bases de données actuelles](#afficher-les-bases-de-données-actuelles)
* [Les measurements et les séries](#les-measurements-et-les-séries)
  * [Afficher les *measurements* de la base de données actuelles](#afficher-les-measurements-de-la-base-de-données-actuelles)
  * [Afficher les *séries* de la base de données actuelles](#afficher-les-séries-de-la-base-de-données-actuelles)
  * [Afficher seulement une séries de la base de données actuelles](#afficher-seulement-une-séries-de-la-base-de-données-actuelles)
* [Les tags](#les-tags)
  * [Afficher les tags/values d'une série](#afficher-les-tagsvalues-dune-série)
  * [Afficher seulement un tags/values d'une série](#afficher-seulement-un-tagsvalues-dune-série)
    * [Afficher les tags/values au moyen d'une requête avec un pseudo LIKE SQL](#afficher-les-tagsvalues-au-moyen-dune-requête-avec-un-pseudo-like-sql)
* [Combien d'enregistrement dans une série](#combien-denregistrement-dans-une-série)
* [Compte le nombre de records de toutes les valeurs d'un tags d'une série](#compte-le-nombre-de-records-de-toutes-les-valeurs-dun-tags-dune-série)
* [Compte le nombre de records de seulement une valeur d'un tags d'une série](#compte-le-nombre-de-records-de-seulement-une-valeur-dun-tags-dune-série)
* [Effacement d'une série avec un tag/value !](#effacement-dune-série-avec-un-tagvalue-)
<!-- /TOC -->


## Astuces
### Partage des secrets dans ce petit manuel !
Afin de rendre générique les requêtes CURL de ce petit manuel et de ne pas partager des secrets dans ce petit manuel ;-) les secrets **doivent** être mis **avant** dans des *variables d'environnement* avec ce petit script que l'on gardera dans son *Keypass* préféré:

```
cat '/Volumes/Keybase (zuzu)/private/zuzu59/influxdb_secrets.sh'
---
#!/bin/bash
#Petit script pour configurer les secrets utilisés pour le système de monitoring Telegraf/InfluxDB/Grafana
#zf191007.1538

#utils: générateur de password, https://www.pwdgen.org/

# UTILISATION:

## Sur sa machine:
### Il faut faire: 
### source '/Volumes/Keybase (zuzu)/private/zuzu59/influxdb_secrets.sh'
### ou 
### source /Keybase/team/epfl_wwp_blue/influxdb_secrets.sh


export dbflux_srv_host=xxx
export dbflux_srv_user=xxx
export dbflux_srv_port=8086

export dbflux_u_admin=admin
export dbflux_p_admin=xxx

export dbflux_u_user=dbuser
export dbflux_p_user=xxx

export dbflux_db=xxx

echo -e "

Les secrets sont:
"
env |grep dbflux
echo -e "
"
---
```

Après il suffira, sur ça machine, juste avant d'utiliser les exemples de ce petit manuel, de faire un:
```
source '/Volumes/Keybase (zuzu)/private/zuzu59/influxdb_secrets.sh'
ou
source /Keybase/team/epfl_wwp_blue/influxdb_secrets.sh
```


### Utilisation de Chronograf pour *explorer* Influxdb
Il n'y a plus d'interface *web* de gestion d'InfluxDB, c'est maintenant *Chronograf* qui s'en charge. 

*Chronograf* est très pratique pour se *balader* dans InfluxDb afin de pouvoir *découvrir* sa structure de données.

Mais comme dans la version *community édition* on ne peut pas protéger son utilisation au moyen d'un *mot de passe*, on doit *l'isoler* en *local* sur le serveur et d'utiliser un ** pour arriver directement sur le serveur.
```
ssh -L 8888:localhost:8888 ubuntu@www.zuzu-test.ml
```
Puis après on peut se connecter sur *Chronograf* simplement avec sont browser sur:

http://localhost:8888/



# Structure des données dans Influxdb
InfluxDB est une base de données keys/values temporelles qui a une certaine structure afin de pouvoir non seulement enregistrer les événement au bon endroit, mais surtout pouvoir utiliser les résultats.

## Le nom de la base de données
On peut avoir plusieurs bases de données dans un serveur InfluxDB

### Afficher les bases de données actuelles
On peut vérifier les bases de données qui se trouvent actuellement dans InfluxDB avec la commande:
```
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=SHOW DATABASES" |jq '.'
```

## Les measurements et les séries
Dans une base de données sur InfluxDB nous avons des measurements et des séries.

### Afficher les *measurements* de la base de données actuelles
On peut vérifier les bases de données qui se trouvent actuellement dans InfluxDB avec la commande:
```
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show MEASUREMENTS " |jq '.'
```

### Afficher les *séries* de la base de données actuelles
On peut vérifier les bases de données qui se trouvent actuellement dans InfluxDB avec la commande:
```
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show SERIES " |jq '.'
```

### Afficher seulement une séries de la base de données actuelles
On peut vérifier les bases de données qui se trouvent actuellement dans InfluxDB avec la commande:
```
export db_measurement=energy
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show SERIES FROM $db_measurement " |jq .
```


## Les tags
Les tags dans InfluxDB sont des étiquettes keys/values que l'on colle aux paires keys/values afin de pouvoir les filtrer plus facilement. Donc dans une série, on a plusieurs tags/values.

### Afficher les tags/values d'une série
```
export db_measurement=energy
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show SERIES FROM $db_measurement " |jq '.'
```

### Afficher seulement un tags/values d'une série
```
export db_measurement=energy
export db_tag=compteur
export db_tag_value=1
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show SERIES FROM $db_measurement  WHERE $db_tag='$db_tag_value' " |jq '.'
```

#### Afficher les tags/values au moyen d'une requête avec un pseudo LIKE SQL
Des fois il peut être intéressant d'afficher les tags/values indépendamment de la série
```
export db_tag=memory
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show SERIES WHERE $db_tag =~ /cron*/ " |jq .
```


# Combien d'enregistrement dans une série
Afin de pouvoir savoir quelle série, tags/values, est grand consommateur de place disque, il faut pouvoir afficher le nombre d'enregistrements d'une série/tags/value

## Compte le nombre de records de toutes les valeurs d'un tags d'une série
```
export db_measurement=energy
export db_tag=compteur
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=SELECT count(*) FROM $db_measurement GROUP BY $db_tag limit 100" |jq .
```

## Compte le nombre de records de seulement une valeur d'un tags d'une série
```
export db_measurement=energy
export db_tag=compteur
export db_tag_value=1
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=SELECT count(*) FROM $db_measurement WHERE $db_tag='$db_tag_value'  limit 100" |jq .
```


# Effacement d'une série avec un tag/value !
Maintenant que l'on connait bien qui consomme quoi on peut commencer à purger les enregistrement inutiles.

```
export db_measurement=energy
export db_tag=memory
export db_tag_value=tmr_socat1_69

## Affichage pour être certain de ce que l'on veut effacer
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show SERIES FROM $db_measurement WHERE $db_tag='$db_tag_value' " |jq .

curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=SELECT count(*) FROM $db_measurement WHERE $db_tag='$db_tag_value'  limit 100" |jq .


## Effacement de la série/tag/value
## ATENTION, il faut être certain de son coup !
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=drop SERIES FROM $db_measurement WHERE $db_tag='$db_tag_value' " |jq .

## Vérification que c'est bien effacé
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show SERIES FROM $db_measurement WHERE $db_tag='$db_tag_value' " |jq .

curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=SELECT count(*) FROM $db_measurement WHERE $db_tag='$db_tag_value'  limit 100" |jq .













SERIES FROM <measurement_name[,measurement_name]> WHERE <tag_key>='<tag_value>'



curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show series where bolo_ruru=''" |jq '.' |head -n 30




curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show SERIES FROM bolo_ruru " |jq .

curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=show SERIES FROM bolo_ruru WHERE capteur='th1' " |jq .



curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin&db=$dbflux_db"  --data-urlencode "q=SELECT count(*) FROM energy WHERE value='nb_waiting_60'  limit 100" |jq .


