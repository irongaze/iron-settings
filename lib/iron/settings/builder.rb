class Settings
  
  # Mirror to the Cursor class, this class helps extend and expand a settings
  # hierarchy.
  class Builder
  
    def self.define(group, &block)
      builder = self.new(group)
      builder.define(&block)
    end
  
    # Bind to a group/root
    def initialize(group)
      @group = group
    end
    
    # Define in block mode
    def define(&block)
      DslProxy.exec(self, &block)
    end
    
    # Create a new sub-group, yield for definition if block passed
    def group(name, &block)
      verify_key?(name)
      group = @group.find_group(name)
      unless group
        verify_available?(name, :group)
        group = @group.add_group(name)
      end
      
      # Chain it
      builder = self.class.new(group)
      builder.define(&block) if block
      builder
    end
    
    def method_missing(method, *args, &block)
      type = method.to_s
      
      if Settings.data_types.include?(type.gsub('_list','').to_sym)
        type = type.to_sym
        name = args[0]
        default = args[1]
        verify_key?(name)
        verify_available?(name, :entry)
        @group.add_entry(name, type, default, &block)
      else
        super
      end
    end
    
    def respond_to_missing?(method, include_private = false)
      Settings.data_types.include?(method.to_s.gsub('_list','').to_sym)
    end

    protected

    # Raise's if name already in use for the group
    def verify_available?(name, type)
      unless @group.find_item(name).nil?
        raise RuntimeError.new("#{type.capitalize}'s name '#{name}' already defined for settings group: #{@group.key}")
      end
    end
  
    def verify_key?(key)
      unless key.is_a?(String) && key.match(/^[a-z][a-z0-9_]*$/)
        raise RuntimeError.new("Key '#{key}' is not a valid group/entry key while defining settings group #{@group.key} - must be a string with a-z, 0-9, or _ chars")
      end
    end
  end
  
end