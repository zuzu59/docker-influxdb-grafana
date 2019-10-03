# InfluxDB & Grafana sur Docker avec push en curl des datas

Système complet de InfluxDB/Grafana pour pouvoir envoyer des données à InfluxDB via un simple 'curl'.

## Utilisation
Simplement faire:

```
./start.sh
```

Après, il faut démarrer l'exemple de générateur de données pour faire les tests du système avec:

```
./example.sh
```

Et enfin configurer la data source de Grafana au moyen de la copie d'écran:

```
grafana_configuration_data_source.png
```

et finalement configurer un petit dashboard au moyen de la copie d'écran:

```
grafana_configuration_dashboard.png  
```

## Et la suite ?
Ben, après faut regarder comment cela fonctionne dans le fichier:

```
example.sh
```


## Astuces
### Partage des sercrets dans ce README !
Ce qui est bien avec la DB d'InfluxDB, c'est que l'on peut tout gérer via des requêtes *curl* !<br>
Afin de ne pas partager des secrets dans ce README ;-) les secrets **doivent** être mis **avant** dans des variables d'environnement avec:

```
export db_u_admin=xxx
export db_p_admin=yyy
export db_u_=aaa
export db_p_=bbb

```



### Création d'une nouvelle DB sur InfluxDB via une requête *curl*
Ne pas oublier de *partager* ses *secrets* !<br>
Après on peut très facilement *voir* quelles DB nous avons avec:

```
curl -i -XPOST "http://www.zuzutest.ml:8086/query?u=$db_u_admin&p=$db_p_admin" --data-urlencode "q=show databases"
```

Puis créer une nouvelle DB avec:

```
curl -i -XPOST "http://www.zuzutest.ml:8086/query?u=$db_u_admin&p=$db_p_admin" --data-urlencode "q=CREATE DATABASE tutu"
```




### Utilisation de la console Chronograf en remote
La console web, Chronograf, d'administration de la DB InfluxDB n'a pas de *login* pour sécuriser l'accès et que le serveur se trouve sur Internet (c'est le but), cette console se retrouve sur Internet sans protection.<br>
L'astuce consiste à la faire tourner (via docker-compose) en *localhost* seulement !<br>
Pour pouvoir y accéder en *remote* il faut simplement créer un tunnel ssh *forward* dessus:

```
ssh -L 8888:localhost:8888 ubuntu@www.zuzutest.ml
```

Après depuis son *browser* on y accède par:

```
http://localhost:8888
```


## Documentation

https://docs.influxdata.com/influxdb/v1.7/administration/security/
https://docs.influxdata.com/influxdb/v1.7/administration/authentication_and_authorization/#set-up-authentication
https://docs.influxdata.com/influxdb/v1.7/administration/authentication_and_authorization/#user-management-commands
https://docs.influxdata.com/influxdb/v1.7/tools/api/#write-http-endpoint
https://docs.influxdata.com/influxdb/v1.7/guides/writing_data/
https://docs.influxdata.com/influxdb/v1.7/tools/shell/


zf190809.1149, zf191003.1538
