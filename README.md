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


## Documentation

https://docs.influxdata.com/influxdb/v1.7/administration/security/
https://docs.influxdata.com/influxdb/v1.7/administration/authentication_and_authorization/#set-up-authentication
https://docs.influxdata.com/influxdb/v1.7/administration/authentication_and_authorization/#user-management-commands
https://docs.influxdata.com/influxdb/v1.7/tools/api/#write-http-endpoint
https://docs.influxdata.com/influxdb/v1.7/guides/writing_data/
https://docs.influxdata.com/influxdb/v1.7/tools/shell/


zf190806.1141
