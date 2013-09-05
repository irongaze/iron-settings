class Settings
  
  # Base class for groups and entries - provides our structure
  class Node
    
    # Used to separate node names in a full key
    NODE_SEPARATOR = '.'.freeze

    # All nodes have these items...
    attr_accessor :root, :parent, :name, :key
    
    def initialize(parent, name = nil)
      # Validate name
      unless parent.nil? || name.match(/[a-z0-9_]+/)
        raise ArgumentError.new("Invalid settings key name '#{name}' - may only contain a-z, 0-9 and _ characters")
      end
      
      @parent = parent
      @name = name

      if @parent.nil?
        # We are the root!
        @root = self
        @key = nil
      else
        # Normal node, chain ourselves
        @root = parent.root
        if parent.key.blank?
          @key = name
        else
          @key = [@parent.key, name].join(NODE_SEPARATOR)
        end
      end
    end

    def group?
      false
    end

    def entry?
      false
    end
    
  end
  
end