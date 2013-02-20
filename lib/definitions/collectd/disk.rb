dashboard "disks" do
  graph "disk_octets" do
    [ "read", "write" ].each do |type|
      metric "disk_octets_#{type}" do
        rrd %r{disk-(?<disk>[\w\-]+)/disk_octets.rrd}
        ds type
        title "Disk $disk octets #{type}"
      end
    end

    layout :line
    title "Disk $disk I/O"
    scope "disk"
  end

  title "Disks"
end
