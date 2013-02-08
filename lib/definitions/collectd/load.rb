metric "load1" do
  rrd "load/load.rrd"
  ds "shortterm"
  title "Load average 1min"
end

metric "load5" do
  rrd "load/load.rrd"
  ds "midterm"
  title "Load average 5min"
end

metric "load15" do
  rrd "load/load.rrd"
  ds "longterm"
  title "Load average 15min"
end

graph "load" do
  metrics [ "load1", "load5", "load15" ]
  layout :line
  title "Load average"
  scope :entity
end
