[ "used", "free" ].each do |x|
  metric "df_#{x}" do
    rrd %r{df/df-(?<mount>\S+).rrd}
    ds x
    title "Disk space #{x} on $mount"
  end
end

graph "df" do
  metrics [ "df_used", "df_free" ]
  layout :area
  title "Disk space on $mount"
  scope "mount"
end
