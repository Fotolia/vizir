dashboard "network" do
  [ "discards", "octets", "packets" ].each do |type|
    graph "if_#{type}" do
      [ "tx", "rx" ].each do |dir|
        metric "if_#{type}_#{dir}" do
          rrd %r{snmp/if_#{type}-(?<iface>[\w\-_]+).rrd}
          ds dir
          title "Interface $iface #{dir} #{type} (SNMP)"
        end
      end

      layout :line
      title "Interface $iface #{type} (SNMP)"
      scope "iface"
    end
  end
end
