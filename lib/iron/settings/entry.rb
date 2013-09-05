class Settings

  # Represents a leaf in our structure, has a value
  class Entry < Settings::Node
  
    attr_accessor :type, :default
  
    def initialize(parent, type, name, default)
      super(parent, name)

      @type = type
      @default = default.respond_to?(:call) ? default : Settings.parse(default, type)
    end
  
    def entry?
      true
    end
  
    def default_value(root_cursor, context = nil)
      return nil if @default.nil?
      @default.respond_to?(:call) ? Settings.parse(@default.call(context), @type) : DslProxy.exec(root_cursor, @default, context)
    end
  
  end
  
end