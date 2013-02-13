graph "memory" do
  %w(active used inactive buffered wired cache cached free).each do |type|
    metric "memory_#{type}" do
      rrd %r{memory/memory-#{type}.rrd}
      ds "value"
      title "Memory #{type.capitalize}"
    end
  end

  layout :area
  title "Memory"
  scope :entity
end
