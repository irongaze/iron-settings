class Settings
  
  # Groups contain a set of items - other groups and entries - that
  # can be traversed by the Cursor to read out or set values.
  class Group < Settings::Node
  
    # Create and set up a new group with the given name
    # and optional parent
    def initialize(parent, name = nil)
      super
      @nodes = {}
    end
    
    def nodes
      @nodes
    end

    def group?
      true
    end
    
    def [](key)
      find_item(key)
    end
  
    # def _add_node(item)
    #   @nodes[item._key] = 
  
    # Add a group to our list of items, and define
    # a getter to access it by name
    def add_group(name)    
      # Add getter for the group
      instance_eval <<-eos
        def #{name}
          find_group('#{name}')
        end
      eos

      group = Group.new(self, name)
      @nodes[name] = group
      group
    end
  
    # Simply access a given group by name
    def find_group(key)
      group = @nodes[key.to_s]
      group.is_a?(Group) ? group : nil
    end
  
    def add_entry(name, type, default = nil, &block)
      default = block unless block.nil?
      entry = Settings::Entry.new(self, type, name, default)
      @nodes[name] = entry
      entry
    end

    def find_entry(name)
      entry = @nodes[name.to_s]
      entry.is_a?(Settings::Entry) ? entry : nil
    end

    def get_entry_val(name)
      entry = find_entry(name)
      return nil unless entry
      entry.value
    end
  
    def set_entry_val(name, value)
      entry = find_entry(name)
      return unless entry
      entry.value = value
    end
    
    def find_item(key)
      @nodes[key.to_s]
    end
  
    # Returns all child entries for this group, optionally recursing
    # to extract sub-groups' entries as well
    def entries(include_children = true)
      @nodes.values.collect do |item|
        if item.entry?
          item
        elsif include_children
          item.entries(include_children)
        else 
          []
        end
      end.flatten
    end
    
    # Returns all groups that are children of this group
    def groups(include_children = false)
      list = @nodes.values.select {|i| i.group?}
      if include_children
        list += list.collect {|i| i.groups}.flatten
      end
      list
    end
  
  end
end