cnx_types = %w( active reading waiting writing )

cnx_types.each do |type|
  metric "nginx_connections_#{type}" do
    rrd %r{nginx/nginx_connections-#{type}.rrd}
    ds "value"
    title "Connections #{type}"
  end
end

graph "nginx_connections" do
  metrics cnx_types.map { |t| "nginx_connections_#{t}" }
  layout :area
  title "Nginx Connections"
  scope :entity
end

metric "m_nginx_requests" do
  rrd %r{nginx/nginx_requests.rrd}
  ds "value"
  title "Requests per second"
end

graph "nginx_requests" do
  metrics ["m_nginx_requests"]
  layout :line
  title "Nginx Requests"
  scope :entity
end
