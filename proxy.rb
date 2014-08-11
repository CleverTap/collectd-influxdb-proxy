require 'sinatra'
require 'sinatra/config_file'
require 'logger'
require 'json'
require 'net/http'

config_file 'config.yml'


set bind: settings.proxy_bind_ip
set port: settings.proxy_bind_port


before do
  logger.level = settings.log_level
end

post '/' do

  incoming_metrics = JSON.parse(request.body.read)
  influxdb_payload = Array.new()
  logger.debug "Incoming data from Collectd => #{incoming_metrics.inspect}"
  incoming_metrics.length.times do |i|
    incoming_metrics[i]['dsnames'].length.times do |j|
      metric = incoming_metrics[i]
      logger.debug "Extracted metric => #{metric.inspect}"
      influxdb_formatted_metric = Hash.new
      influxdb_formatted_metric[:name] = metric['host']
      influxdb_formatted_metric[:name] += '.' + metric['plugin'] if metric['plugin'].empty? == false
      influxdb_formatted_metric[:name] +='.' + metric['plugin_instance'] if metric['plugin_instance'].empty? == false
      influxdb_formatted_metric[:name] += '.' + metric['type'] if  metric['type'].empty? == false
      influxdb_formatted_metric[:name] += '.' + metric['type_instance'] if  metric['type_instance'].empty? == false
      influxdb_formatted_metric[:name] += '.' + metric['dsnames'][j] if metric['dsnames'][j].empty? == false
      influxdb_formatted_metric[:columns] = %w(time value)
      influxdb_formatted_metric[:points] = [[metric['time'] * 1000, metric['values'][j]]]
      influxdb_payload.push(influxdb_formatted_metric)
    end
  end
  logger.debug "Data being submitted to InfluxDB => #{influxdb_payload.inspect}"

  # HTTP request to InfluxDB /db/test/series?u=test&p=test
  influxdb_uri = URI("http://#{settings.influxdb_host}:#{settings.influxdb_port}/db/#{settings.influxdb_database}/series?u=#{settings.influxdb_username}&p=#{settings.influxdb_password}")


  influxdb_connection = Net::HTTP.start(influxdb_uri.hostname, influxdb_uri.port) do |http|
    influxdb_req = Net::HTTP::Post.new(influxdb_uri.path + '?' + influxdb_uri.query)
    influxdb_req.set_body_internal(influxdb_payload.to_json)
    influxdb_res = http.request influxdb_req

  end


end
