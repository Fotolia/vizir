module Vizir
  class DSL
    attr_accessor :objects, :type, :errors
    attr_reader :parent, :level

    @@members = [:metric, :graph, :dashboard]
    @@collections = {:metrics => :metric, :graphs => :graph}

    def initialize(parent = nil)
      @objects = Hash.new
      @errors = Array.new
      @level = nil
      @parent = parent
      @root = parent.nil? ? self : root()
    end

    @@members.each do |method|
      define_method method do |*args, &block|
        @level = method
        if !root? and @parent.level != @@members[@@members.index(method) + 1]
          error("#{method} #{args.first} not allowed in #{@parent.level}")
        end
        if block
          # create a "sub-"context to evaluate nested directives
          context = DSL.new(self)
          context.instance_eval &block
          # create object definition in the root hash
          object = Hash.new
          object[:name] = args.first
          object[:type] = @root.type if method == :metric
          @root.objects[method] ||= Array.new
          @root.objects[method] << object.merge(context.objects)
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
          error("#{method} #{args.first} not allowed in #{@parent.level}")
        end
        if root?
          error("#{method} #{args.first} not allowed in top scope")
        end
        error("ignoring block in #{method} #{args}") if block
        @objects[method] ||= Hash.new
        if args.count == 1
          args.flatten.each{|a| @objects[method][a] = nil}
        else
          @objects[method][args.shift] = args.shift
        end
      end
    end

    def method_missing(method, *args, &block)
      error("#{method} #{args.first} not allowed in top scope") if root?
      error("ignoring block in #{method} #{args.first}") if block_given?
      @objects[method] = args.count > 1 ? args : args.first
    end

    def semantic_check
      @@members.each_with_index do |member, index|
        obj_list = objects[member]
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
          # Check for missing sub key (metrics in graph, graphs in dashboard)
          obj_list.select{|obj| !obj[sub_coll]}.each do |obj|
            error("#{obj[:name]} #{member} has no #{sub_coll}")
          end
          # Check for undefined sub elements
          obj_list.map{|obj| obj[sub_coll].keys if obj[sub_coll]}.flatten.delete_if{|i| i.nil?}.each do |sub_obj|
            error("undefined #{sub_mem} #{sub_obj}") if objects[sub_mem].select{|obj| obj[:name] == sub_obj}.empty?
          end
        end

        # Check for unused objects (metrics, graphs) (?)
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

    def error(message)
      @root.errors << message
    end

    class << self
      def parse(defs_path)
        dsl = new
        Dir.glob(File.join(File.expand_path(defs_path), "**/*.rb")) do |file|
          folder = File.basename(File.dirname(file))
          dsl.type = "#{folder}_metric".camelcase
          dsl.instance_eval(File.read(file))
        end
        dsl.semantic_check
        dsl
      end

      def load_dsl
        Vizir::Application.config.dsl = parse(Vizir::Application.config.definitions_path).objects
        nil
      end

      def data
        begin
          Vizir::Application.config.dsl
        rescue
          load_dsl
        end
      end

      @@members.each do |method|
        define_method "#{method}s" do |*args|
          data[method] if data
        end
      end
    end
  end
end
