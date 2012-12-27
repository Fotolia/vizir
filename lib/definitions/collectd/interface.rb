[ "errors", "octets", "packets" ].each do |type|
  [ "tx", "rx" ].each do |dir|
    metric "if_#{type}_#{dir}" do
      rrd %r{interface/if_#{type}-(?<iface>\w+).rrd}
      ds dir
      title "Interface #{dir} #{type}"
    end
  end
end
