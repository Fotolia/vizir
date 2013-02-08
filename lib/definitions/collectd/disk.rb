[ "read", "write" ].each do |type|
  metric "disk_octets_#{type}" do
    rrd %r{disk-(?<disk>\w+)/disk_octets.rrd}
    ds type
    title "Disk $disk octets #{type}"
  end
end

graph "disk_octets" do
  metrics [ "disk_octets_read", "disk_octets_write" ]
  layout :line
  title "Disk $disk I/O"
  scope "disk"
end
