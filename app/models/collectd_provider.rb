require 'rrd'

class CollectdProvider < Provider
  attr_custom :rrd_path, :collectd_sock, :rrdcached_sock

  def get_entities
    Dir.glob("#{rrd_path}/*/").map {|e| e.split('/').last }.uniq.each do |e|
      Entity.new(:name => e).save
    end
  end

  def get_metrics
    metric_list = []
    instance_list = []

    Dir.glob("#{rrd_path}/**/*.rrd").each do |filename|
      parts = filename.match(/#{rrd_path}\/(?<host>.*?)\/(?<rrd>.*)/)
      dss = get_ds_list(filename)
      dss.each do |ds|
        metric = nil
        metric_def = nil
        rrd_match = nil

        if metric_defs = Vizir::DSL[:metric]["CollectdMetric"]
          metric_defs.each do |m|
            if rrd_match = m[:rrd].match(parts[:rrd]) and m[:ds] == ds
              metric_def = m
              break
            end
          end
          unless metric_def.nil?
            metric = CollectdMetric.new(:name => metric_def[:name], :rrd => metric_def[:rrd], :ds => ds)
          end
        end

        # Default, no DSL found
        if metric.nil?
          metric = CollectdMetric.new(:name => "#{parts[:rrd]}:#{ds}", :rrd => parts[:rrd], :ds => ds) if metric.nil?
        end

        instance_list << i = Instance.new
        i.assign_attributes({ :entity => Entity.find_by_name(parts[:host]), :provider => self }, :without_protection => true)
        i.details = rrd_match.to_hash unless rrd_match.nil?
        if metric_i = metric_list.index(metric)
          i.metric = metric_list[metric_i]
        else
          metric_list << metric
          i.metric = metric
        end
      end
    end

    metric_list.each {|m| m.save}
    instance_list.each {|i| i.save}

    nil
  end

  def get_values(options = {})
    rrd_rel_path = "#{options["entity"]}/#{options["rrd"]}"
    rrd_abs_path = "#{rrd_path}/#{rrd_rel_path}"
    start  = options["start"]
    finish = options["end"]

    flush(rrd_rel_path, collectd_sock) if collectd_sock
    flush(rrd_abs_path, rrdcached_sock) if rrdcached_sock

    rrd = RRD::Base.new(rrd_abs_path)
    rrd_data = rrd.fetch(:average, :start => start, :end => finish)

    # first entry describes format
    ds_index = rrd_data.shift.index(options["ds"])

    data = []

    last_valid = 0
    rrd_data.each do |tuple|
      value = tuple[ds_index]
      if value.nan?
        value = last_valid
      else
        last_valid = value
      end
      data << { "x" => tuple[0], "y" => value }
    end

    data
  end

  private

  def get_ds_list(rrd_file)
    rrd = RRD::Base.new(rrd_file)
    rrd.info.keys.select {|v| v =~ /^ds/ }.map {|v| v[/^ds\[(\S+)\]\..*$/, 1] }.uniq
  end

  def flush(path, socket)
    socket = UNIXSocket.new(socket)
    socket.puts "FLUSH \"#{path}\""
    socket.gets
    socket.close
  end
end
