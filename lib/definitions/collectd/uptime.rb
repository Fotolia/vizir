metric "m_uptime" do
  rrd %r{uptime/uptime.rrd}
  ds "value"
  title "Uptime"
end

graph "uptime" do
  metrics [ "m_uptime" ]
  layout :line
  title "Uptime"
  scope :entity
end
