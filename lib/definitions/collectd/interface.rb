dashboard "network" do
  [ "errors", "octets", "packets" ].each do |type|
    graph "if_#{type}" do
      [ "tx", "rx" ].each do |dir|
        # Collectd 4.x
        metric "if_#{type}_#{dir}_4" do
          rrd %r{interface/if_#{type}-(?<iface>\w+).rrd}
          ds dir
          title "Interface $iface #{dir} #{type}"
        end

      # Collectd 5.x
        metric "if_#{type}_#{dir}_5" do
          rrd %r{interface-(?<iface>\w+)/if_#{type}.rrd}
          ds dir
          title "Interface $iface #{dir} #{type}"
        end
      end

      layout :line
      title "Interface $iface #{type}"
      scope "iface"
    end
  end
end
