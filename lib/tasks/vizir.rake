require 'yaml'

namespace :vizir do
  providers_yml = "#{Rails.root}/config/providers.yml"

  task :init => :environment do
    unless File.exists?(providers_yml)
      puts "Provider config file #{providers_yml} not found. Create it according to doc."
      exit
    end
    providers = YAML.load_file(providers_yml)
    providers.each do |name, attrs|
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

  task :load => :environment do
    if Provider.count == 0
      puts "No provider found. Create #{providers_yml} and run 'rake vizir:init'."
      exit
    end
    Provider.all.each do |provider|
      provider.load_entities
      provider.load_metrics
    end
  end
end
