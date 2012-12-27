class HashBuilder
  def initialize
    @hash = {}
  end

  def method_missing(name, *args, &block)
    return @hash[name] = args.first
  end

  def build
    @hash
  end
end
