dashboard "nginx" do
  graph "nginx_connections" do
    %w(reading waiting writing).each do |type|
      metric "nginx_connections_#{type}" do
        rrd %r{nginx/nginx_connections-#{type}.rrd}
        ds "value"
        title "Connections #{type}"
      end
    end

    layout :area
    title "Nginx Connections"
    scope :entity
  end

  graph "nginx_requests" do
    metric "nginx_requests" do
      rrd %r{nginx/nginx_requests.rrd}
      ds "value"
      title "Requests per second"
    end

    layout :line
    title "Nginx Requests"
    scope :entity
  end

  title "Nginx"
end
