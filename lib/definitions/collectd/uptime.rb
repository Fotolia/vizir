graph "uptime" do
  metric "uptime" do
    rrd %r{uptime/uptime.rrd}
    ds "value"
    title "Uptime"
  end

  layout :line
  title "Uptime"
  scope :entity
end
