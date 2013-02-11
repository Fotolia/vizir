types = %w(used reserved free)

types.each do |type|
  # Simple DF
  metric "df_#{type}" do
    rrd %r{df/df-(?<mount>\S+).rrd}
    ds type
    title "Disk space #{type} on $mount"
  end

  # Complex DF
  metric "df_complex_#{type}" do
    rrd %r{df-(?<mount>\S+)/df_complex-#{type}.rrd}
    ds "value"
    title "Disk space #{type} on $mount"
  end
end

graph "df" do
  metrics types.map {|t| "df_complex_#{t}"} + types.map {|t| "df_#{t}"}
  layout :area
  title "Disk space on $mount"
  scope "mount"
end

