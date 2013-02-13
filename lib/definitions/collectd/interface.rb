[ "errors", "octets", "packets" ].each do |type|
  # Collectd 4.x
  [ "tx", "rx" ].each do |dir|
    metric "if_#{type}_#{dir}" do
      rrd %r{interface/if_#{type}-(?<iface>\w+).rrd}
      ds dir
      title "Interface $iface #{dir} #{type}"
    end
  end

  # Collectd 5.x
  [ "tx", "rx" ].each do |dir|
    metric "if_#{type}_#{dir}" do
      rrd %r{interface-(?<iface>\w+)/if_#{type}.rrd}
      ds dir
      title "Interface $iface #{dir} #{type}"
    end
  end

  graph "if_#{type}" do
    metrics [ "if_#{type}_tx", "if_#{type}_rx" ]
    layout :line
    title "Interface $iface #{type}"
    scope "iface"
  end
end
