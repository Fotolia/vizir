module Vizir
  class DSL
    attr_accessor :objects, :errors
    attr_reader :parent, :level, :file

    @@members = [:metric, :graph, :dashboard]
    @@collections = {:metrics => :metric, :graphs => :graph}

    def initialize(parent = nil)
      @objects = Hash.new
      @refs = Hash.new
      @errors = Array.new
      @level = nil
      @parent = parent
      @root = parent.nil? ? self : root()
    end

    @@members.each do |method|
      define_method method do |*args, &block|
        @level = method
        if !root? and @parent.level != @@members[@@members.index(method) + 1]
          error("#{method} #{args.first} not allowed in #{@parent.level}", true); return
        end
        if block
          # create object definition in the root hash
          @root.create_object(method, args.first, block)
          # create a reference on the former in the local hash
          send(method, args.first) unless root?
        else
          send("#{method}s", *args)
        end
      end
    end

    @@collections.keys.each do |method|
      define_method method do |*args, &block|
        if !root? and @parent.level != @@members[@@members.index(@@collections[method]) + 1]
          error("#{method} #{args.first} not allowed in #{@parent.level}", true); return
        end
        if root?
          error("#{method} #{args.first} not allowed in top scope", true); return
        end
        if block
          error("ignoring block in #{method} #{args}", true); return
        end
        @objects[method] ||= Hash.new
        if args.count == 1
          args.flatten.each{|a| @objects[method][a] = nil}
        else
          @objects[method][args.shift] = args.shift
        end
      end
    end

    def method_missing(method, *args, &block)
      if root?
        error("#{method} #{args.first} not allowed in top scope", true); return
      end
      if block_given?
        error("ignoring block in #{method} #{args.first}", true); return
      end
      @objects[method] = args.count > 1 ? args : args.first
    end

    def semantic_check
      @@members.each_with_index do |member, index|
        obj_list = @objects[member]
        next unless obj_list

        # Check for duplicate names
        obj_list.group_by {|obj| obj[:name]}.each do |name,occurences|
          if occurences.count > 1
            new = occurences.first
            occurences.each {|o| new.deep_merge!(o); obj_list.delete(o)}
            obj_list << new
          end
        end

        # Check for badly defined objects (graphs, dashboards)
        if member != @@members.first
          sub_mem = @@members[index - 1]
          sub_coll = @@collections.invert[sub_mem]

          # Check for undefined sub elements
          obj_list.each do |obj|
            if obj[sub_coll]
              obj[sub_coll].keys.select{|x| !@refs[sub_mem].include?(x)}.each do |sub_obj|
                error("undefined #{sub_mem} #{sub_obj} in #{member} #{obj[:name]}. deleting")
                obj[sub_coll].delete(sub_obj)
              end
            end
          end

          # Check for missing sub key (metrics in graph, graphs in dashboard)
          obj_list.select{|obj| !obj[sub_coll] or obj[sub_coll].empty?}.each do |obj|
            error("#{obj[:name]} #{member} has no #{sub_coll}. deleting")
            obj_list.delete(obj)
          end
        end
      end
    end

    def create_object(type, name, block)
      @objects[type] ||= Array.new
      @refs[type] ||= Array.new
      # create a "sub-"context to evaluate nested directives
      context = DSL.new(self)
      context.instance_eval &block
      object = {:name => name}
      object[:type] = @type if type == :metric
      @objects[type] << object.merge(context.objects)
      @refs[type] << name
    end

    def run(file, type)
      @file = file
      @type = "#{type}_metric".camelcase
      begin
        instance_eval(File.read(file), file)
      rescue Exception => e
        error("invalid definition file, skipping (#{e.message})")
      end
    end

    def root
      _parent = self
      loop do
        break if _parent.parent.nil?
        _parent = _parent.parent
      end
      _parent
    end

    def root?
      @root == self
    end

    def error(message, stack = false)
      message += " (#{caller(0).select{|i| i.match(/^#{@root.file}/)}.first})" if stack
      @root.errors << message
    end

    class << self
      def parse(defs_path)
        dsl = new
        Dir.glob(File.join(File.expand_path(defs_path), "**/*.rb")) do |file|
          dsl.run(file, File.basename(File.dirname(file)))
        end
        dsl.semantic_check
        dsl
      end

      def load_dsl
        dsl = parse(Vizir::Application.config.definitions_path)
        Vizir::Application.config.dsl_objects = dsl.objects
        Vizir::Application.config.dsl_errors = dsl.errors
        nil
      end

      [:objects, :errors].each do |method|
        define_method method do
          begin
            Vizir::Application.config.send("dsl_#{method}")
          rescue
            load_dsl
          end
        end
      end

      @@members.each do |method|
        define_method "#{method}s" do |*args|
          objects[method] if objects
        end
      end
    end
  end
end
