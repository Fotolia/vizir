require 'yaml'

namespace :vizir do
  providers_yml = "#{Rails.root}/config/providers.yml"

  desc "Load provider config"
  task :setup => :environment do
    begin
      @providers = YAML.load_file(providers_yml)
    rescue Exception => e
      puts e.message
      exit 1
    end
  end

  desc "Initialize application by creating metric providers"
  task :init => :setup do
    @providers.each do |name, attrs|
      if Provider.find_by_name(name)
        puts "Provider #{name} already exists"
      else
        provider_type = "#{attrs["type"].underscore}_provider".camelcase.constantize
        attrs.delete("type")
        p = provider_type.new(:name => name)
        p.assign_attributes(attrs)
        if p.valid?
          p.save
        else
          p p.errors
        end
      end
    end
  end

  desc "Load provided entities and metrics in database"
  task :load => :setup do
    if Provider.count == 0
      puts "No provider found. Create #{providers_yml} and run 'rake vizir:init'."
      exit
    end
    Provider.all.each do |provider|
      ignore = @providers[provider.name]["ignore_unknown_metrics"] ? true : false
      provider.load_metrics(ignore)
    end
    Graph.load_defs
    Dashboard.load_defs
  end
end
