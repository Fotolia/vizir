module StiHelpers
  def attr_custom(*names)
    names.each do |name|
      # define attribute getter
      define_method name do
        self.details ||= {}
        self.details[name.to_s]
      end
      # define attribute setter
      define_method "#{name}=".to_sym do |arg|
        self.details ||= {}
        self.details[name.to_s] = arg
      end
      # add attribute in attr_accessible
      attr_accessible name
    end
  end
end
