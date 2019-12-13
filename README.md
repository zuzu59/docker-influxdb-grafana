# InfluxDB & Grafana sur Docker avec push en curl des datas

Système complet de InfluxDB/Grafana pour pouvoir envoyer des données temporelles à InfluxDB via un simple 'curl'.


## Installation et utilisation
Simplement faire:

```
./start.sh
```

**ATTENTION:**
N'oubliez pas **RAPIDEMENT** d'aller changer le password par défault (admin) du compte admin de Grafana !

Et... de faire **tourner une seule fois le script**:

```
./configure_influxdb.sh
```
 afin de configurer le compte admin de InfluxDB !


Pour l'arrêter sans effacer les données:
```
./stop.sh
```

Pour tout purger, y compris les données:
```
./purge.sh
```



## Astuces
### Partage des secrets dans ce README !
Afin de ne pas partager des secrets dans ce README ;-) les secrets **doivent** être mis **avant** dans des *variables d'environnement* avec ce petit script que l'on gardera dans son *Keypass* préféré:

```
cat influxdb_secrets.sh
---
#!/bin/bash
#Petit script pour configurer les secrets utilisés pour le système de monitoring Telegraf/InfluxDB/Grafana
#zf191007.1538

#utils: générateur de password, https://www.pwdgen.org/


# UTILISATION:

## Sur le serveur SSH:
### Il faut ajouter la ligne suivante dans /etc/ssh/sshd_config: AcceptEnv LANG LC_* GIT* EDITOR dbflux_*

## Sur sa machine:
### Il faut faire: source /Keybase/team/epfl_wwp_blue/influxdb_secrets.sh
### Puis se connecter avec: ssh -A -o SendEnv="GIT*, dbflux*" user@host

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

Après il suffira, juste avant d'utiliser ces exemples, de faire un:
```
source /keybase/xxx...xx/influxdb_secrets.sh
```

Et si on se trouve sur une machine distante:
```
ssh -A -o SendEnv="GIT*, dbflux*" czufferey@noc-tst.idev-fsd.ml
env |grep dbflux
ssh-add -l
```

Il faudra aussi modifier ceci dans **/etc/ssh/sshd_config** sur la machine *remote* !
```
# Allow client to pass locale environment variables
AcceptEnv LANG LC_* GIT* EDITOR dbflux_*
```
Puis redémarrer le service sshd avec:
```
sudo systemctl restart sshd.service
```



## Configuration de la base de données influxdb
Ce qui est bien avec la DB d'InfluxDB, c'est que l'on peut tout gérer via des requêtes *curl* !<br>
Il nous suffit donc de rentrer les commandes suivantes pour:

**REMARQUE:**
On peut, pour se simplifier la vie, simplement faire *tourner* ce petit script pour configurer Influx DB selon les paramètres que l'on a indiqués dans les *secrets*:
```
./configure_influxdb.sh
```


### Création d'un compte administrateur
Il faudra d’abord se créer un compte administrateur avec la commande suivante.
```
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query" --data-urlencode "q=CREATE USER $dbflux_u_admin WITH PASSWORD '$dbflux_p_admin' WITH ALL PRIVILEGES"
```


### Création d'une base de données
Puis une base de données ou seront stockée tous nos enregistrements. Le schéma de stockage que vous souhaitez utilisez reste un choix personnel (Une base pour tous les enregistrements, une base par client, par pays etc)
```
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=CREATE DATABASE $dbflux_db"
```


### Afficher les bases de données actuelles
On peut vérifier que cette dernière s’est bien créer avec la commande:
```
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=SHOW DATABASES"
```


### Création d'un utilisateur
Nous allons maintenant créer un utilisateur qui aura le droit d’écrire et de lire dans la base, ce sera cet utilisateur que nous renseignerons dans le fichier de configuration de l’agent chez le client. Il est conseillé pour des questions de sécurité de créer un utilisateur par base:
```
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=CREATE USER $dbflux_u_user WITH PASSWORD '$dbflux_p_user'"
```


### Afficher les utilisateurs actuelles
On peut afficher les utilisateur actuels avec la commande:
```
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=SHOW USERS"
```

#### Sous forme d'un tableau JSON
Ou sous forme de tableau JSON plus facile à lire pour un humain:
```
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=SHOW USERS" | python -m json.tool
```


### Attribution d'une base de données à un utilisateur
Affectons-lui les droits de lecture et d’écriture sur la table.
```
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=GRANT ALL ON $dbflux_db TO $dbflux_u_user"
```

#### Vérifier les privilège pour cet utilisateur
On peut afficher les privilège pour cet utilisateur avec la commande:
```
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=SHOW GRANTS FOR $dbflux_u_user"
```


### Mettre une police de rétention aux données
Nous allons préciser une police de rétention, afin de supprimer automatiquement les données au bout de x heures, jours ou semaines. Dans mon cas je vais supprimer toutes les données de plus d’un an donc 365 jours.
```
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=CREATE RETENTION POLICY <Nom_Police> ON <Nom_Base> DURATION <Durée> REPLICATION 1 DEFAULT"
```


### Que faire en cas d'erreur ?
Si vous souhaitez, en cas d’erreur supprimer des droits, un utilisateur ou une base, la commande DROP suivi du nom de la base ou de l’utilisateur permettra de le supprimer et la commande REVOKE [READ,WRITE,ALL] ON <BaseDeDonnées> FROM <Utilisateur> vous permettra de supprimer les droits de votre choix sur une base donnée pour l’utilisateur donné.


### Tests d'écritures dans la db
On peut après, quand tout est bien configuré, écrire au moyen d'un simple CURL des données temporelles dans la base de données.
Par exemple pour écrire la *puissance* du *compteur* numéro 2 dans la table *energy* on fait simplement:
```
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "energy,compteur=2 puissance=7"
```
On n'a pas besoin de mettre le *timestamp* car InfluxDB enregistre l'heure où l'écriture est arrivée.<br>
Mais il y a moyen de *fixer* le timestamp en l'indiquant en *temps Unix* en nanosecondes à la fin.
 ```
curl -i -XPOST "$dbflux_srv_host:$dbflux_srv_port/write?db=$dbflux_db&u=$dbflux_u_user&p=$dbflux_p_user"  --data-binary "energy,compteur=2 puissance=7 $(date +%s%N)"
```

On peut aussi faire tourner le petit script d'exemple pour générer quelques données:
```
./example.sh
```

### Tests de lecture après les données écrites dans la base de données
Avec cette requête on arrive à *voir* les données qui se trouvent dans la base de données, ici dans les 5 dernières minutes:
```
curl -XPOST "$dbflux_srv_host:$dbflux_srv_port/query?u=$dbflux_u_admin&p=$dbflux_p_admin"  --data-urlencode "q=SELECT sum("puissance") AS "sum_puissance" FROM "db1"."autogen"."energy" WHERE time > now() - 5m AND "compteur"='2' GROUP BY time(1s) FILL(none)" | python -m json.tool
```



## Configuration et utilisation de grafana
### Configuration de la data source
Et enfin configurer la data source de Grafana au moyen de la copie d'écran:
![Image](https://raw.githubusercontent.com/zuzu59/docker-influxdb-grafana/master/img/grafana_configuration_data_source.gif)


### Configuration d'un petit dashboard
Et finalement configurer un petit dashboard au moyen de la copie d'écran:
![Image](https://raw.githubusercontent.com/zuzu59/docker-influxdb-grafana/master/img/grafana_configuration_dashboard.gif)







### Configuration d'un dashboard plus complet
On peut configurer un dashboard nettement plus complet en utilisant les *variables* du *dashboard*, quelques copies d'écran pour aider:








![Image](https://raw.githubusercontent.com/zuzu59/docker-influxdb-grafana/master/img/grafana_configuration_dashboard.gif)









## Utilisation de la console Chronograf en remote
La console web, Chronograf, d'administration de la DB InfluxDB n'a pas de *login* pour sécuriser l'accès et que le serveur se trouve sur Internet (c'est le but), cette console se retrouve sur Internet sans protection.<br>
L'astuce consiste à la faire tourner (via docker-compose) en *localhost* seulement !<br>
Pour pouvoir y accéder en *remote* il faut simplement créer un tunnel ssh *forward* dessus:

```
ssh -L 8888:localhost:8888 $dbflux_srv_user@$dbflux_srv_host
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
https://theogindre.fr/2018/02/16/mise-en-place-dune-stack-de-monitoring-avec-influxdb-grafana-et-telegraf/
https://blog.octo.com/monitorer-votre-infra-avec-telegraf-influxdb-et-grafana/


## Pense bête à zuzu
Il faut modifier ceci dans /etc/ssh/sshd_config sur la machine remote !
```
# Allow client to pass locale environment variables
AcceptEnv LANG LC_* GIT* EDITOR dbflux_*
```

```
cat /keybase/team/epfl_wwp_blue/influxdb_secrets.sh
```

```
source /Keybase/team/epfl_wwp_blue/influxdb_secrets.sh
ssh -A -o SendEnv="GIT*, dbflux*" czufferey@noc-tst.idev-fsd.ml
env |grep dbflux
ssh-add -l
```





zf190809.1149, zf191213.1026
