class CollectdMetric < Metric
  attr_custom :rrd, :ds

  # TODO: retrieve the above fields
  def dsl_override
    @check_fields = [ :rrd, :ds ]
    super
  end
end
