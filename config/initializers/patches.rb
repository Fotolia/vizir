# Requiring open class patches
Dir["#{Rails.root}/lib/patches/*.rb"].each {|file| require file}
