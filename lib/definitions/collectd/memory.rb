mem_metrics = %w(free active inactive wired cache used buffered cached)
mem_metrics.each do |type|
  metric "memory_#{type}" do
    rrd %r{memory/memory-#{type}.rrd}
    ds "value"
    title "Memory #{type.capitalize}"
  end
end

graph "memory" do
  metrics mem_metrics.map {|m| "memory_#{m}"}
  layout :area
  title "Memory"
  scope :entity
end
