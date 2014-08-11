Collectd to InfluxDB proxy
==========================

Collectd to InfluxDB proxy, written in Sinatra

Takes metrics emitted by Collectd in JSON format using `write_http` and writes it to InfluxDB.

# Configuring Collectd to send metrics to the proxy

```
LoadPlugin "write_http"
<Plugin "write_http">
	<URL "http://192.168.10.100:9090">
	Format "JSON"
	</URL>
</Plugin>
```

where 192.168.10.100 is the host running the proxy on port 9090 (by default)

# Configuring the proxy

1. `git clone https://github.com/wizrocket/collectd-influxdb-proxy.git collectd-influxdb-proxy`
2. `cd collectd-influxdb-proxy`
3. Run `bundle install` to install all dependent gems
4. Copy config.sample.yml to config.yml
5. Change `influxdb_host`, `influxdb_port`, `influxdb_database`, `influxdb_username` and `influxdb_password` to match your environment specific settings under the development block in config.yml
6. Start the proxy by running `nohup ruby proxy.rb -e development &`
7. Watch the logs `tail -f nohup.out`. If Collectd and all the InfluxDB parameters are configured correctly, you should begin seeing data coming in from Collectd and being submitted to InfluxDB for storage.

## Too much info being logged ?

By default the proxy runs in development mode causing a lot of debug information to be logged to disk. When running in production, start the proxy with ``` -e production ```.

