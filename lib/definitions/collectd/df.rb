# Simple DF
[ "used", "free" ].each do |x|
  metric "df_#{x}" do
    rrd %r{df/df-(?<mount>\S+).rrd}
    ds x
    title "Disk space #{x} on $mount"
  end
end

# Complex DF
%w(used free reserved).each do |type|
  metric "df_#{type}" do
    rrd %r{df-(?<mount>\S+)/df_complex-#{type}.rrd}
    ds "value"
    title "Disk space #{type} on $mount"
  end
end

graph "df" do
  metrics [ "df_used", "df_reserved", "df_free" ]
  layout :area
  title "Disk space on $mount"
  scope "mount"
end

