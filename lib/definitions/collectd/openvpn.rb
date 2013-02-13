graph "openvpn_network" do
  [ "tx", "rx" ].each do |type|
    metric "openvpn_network_#{type}" do
      rrd %r{openvpn-(?<file>[a-zA-Z0-9.\-]+)/if_octets-(?<user>[a-zA-Z0-9.\-]+).rrd}
      ds type
      title "iOpenVPN trafic #{type.upcase} for $user"
    end
  end

  layout :line
  title "OpenVPN trafic for $user"
  scope "user"
end

graph "openvpn_users" do
  metric "openvpn_users" do
    rrd %r{openvpn-(?<file>[a-zA-Z0-9.\-]+)/users-.+.rrd}
    ds "value"
    title "Connected Users"
  end

  layout :line
  title "OpenVPN Users"
  scope "file"
end
