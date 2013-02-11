swap_metrics = %w(used free)
swap_metrics.each do |type|
  metric "swap_#{type}" do
    rrd %r{swap/swap-#{type}.rrd}
    ds "value"
    title "Swap #{type.capitalize}"
  end
end

graph "swap" do
  metrics swap_metrics.map {|m| "swap_#{m}"}
  layout :area
  title "Swap Usage"
  scope :entity
end
