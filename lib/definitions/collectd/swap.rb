graph "swap" do
  %w(used free).each do |type|
    metric "swap_#{type}" do
      rrd %r{swap/swap-#{type}.rrd}
      ds "value"
      title "Swap #{type.capitalize}"
    end
  end

  layout :area
  title "Swap Usage"
  scope :entity
end
