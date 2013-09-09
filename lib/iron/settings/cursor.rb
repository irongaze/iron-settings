class Settings
  
  # Cursors handle navigating the settings hierarchy built by our Builder class, allowing
  # getting and setting entry values and inspecting the hierarchy itself.
  class Cursor < DslBuilder
    
    # Start up our cursor bound to a given group in the settings hierarchy, with
    # the value store holding the values for the current context.
    def initialize(group, values, context = nil)
      @group = group
      @values = values
      @context = context
    end
    
    # Provides access to the root of the hierarchy, generally not useful
    # during operations... :-)
    def root
      @group.root
    end
    
    # Returns all entry keys at the cursor's current position, and optionally
    # including all child keys.  If the cursor is at a sub-group node, keys
    # will be relative to that node.
    def entry_keys(include_all = true)
      keys = @group.entries(include_all).collect {|e| e.key }
      unless @group.key.blank?
        keys.collect! {|k| k.gsub(@group.key + '.', '') }
      end
      keys
    end
    
    # Returns all group keys
    def group_keys(include_all = false)
      keys = @group.entries(include_all).collect {|e| e.key }
      unless @group.key.blank?
        keys.collect! {|k| k.gsub(@group.key + '.', '') }
      end
      keys
    end
    
    # Finds the item (group or entry) in the hierarchy matching the provided
    # relative key.  Raises a RuntimeError on unknown keys.
    def find_item(key)
      item = @group
      key = key.to_s
      parts = key.split(/\./)
      until parts.empty?
        item_key = parts.shift
        item = item.find_item(item_key)
        raise RuntimeError.new("Unknown settings group or entry '#{item_key}' in settings path #{[@group.key,key].list_join('.')}") if item.nil?
      end
      item
    end
    
    # Return Settings::Entry items for entries at this cursor level and optionally below it
    def find_entries(include_all = true)
      @group.entries(include_all)
    end
    
    # Array-like access to the entry value at the specified key
    def [](key, &block)
      item = find_item(key)
      if item.group?
        # Got asked for another group, so create a new cursor and do the right thing(tm)
        cursor = Settings::Cursor.new(item, @values)
        DslProxy::exec(cursor, &block) if block
        cursor
      else
        item_value(item)
      end
    end
    
    # Array-like setter for entry values using the specified key
    def []=(key, val)
      item = find_item(key)
      if item
        @values.set_value(item.key, Settings.parse(val, item.type))
      end
      val
    end
    
    # Look for the next item from our current group pointer,
    # returning a new cursor if the item is a sub-group, or the value
    # of the requested entry if the item is a leaf in the
    # hierarchy tree.
    def method_missing(method, *args, &block)
      method = method.to_s
      query = method.ends_with?('?')
      assignment = method.ends_with?('=')
      method.gsub!(/[=\?]+/,'')
      
      # Look up the item
      item = @group.find_item(method)
      if item.nil?
        # Unknown item name, whoops.
        raise RuntimeError.new("Unknown settings group or entry '#{method}' for settings path #{@group.key}")
        
      elsif item.group?
        if query
          # Yes, this group exists
          return true
        else
          # Got asked for another group, so create a new cursor and do the right thing(tm)
          cursor = Settings::Cursor.new(item, @values)
          DslProxy::exec(cursor, &block) if block
          return cursor
        end
        
      elsif item.entry?
        if query
          # Return true if the given item has a non-nil value
          return !item_value(item).nil?
        else
          if args.empty?
            # No args means return the current value (or default if none)
            return item_value(item)
          else
            # With args, we set the current value of the item (if it parses correctly)
            val = Settings.parse(args.first, item.type)
            @values.set_value(item.key, val)
            return args.first
          end
        end
      end
    end
    
    # Counterpart to #method_missing
    def respond_to_missing?(method, include_private = false)
      method = method.to_s.gsub(/[=\?]+/,'')
      item = @group.find_item(method)
      return !item.nil?
    end

    # When true, has non-default value set for the given entry
    def item_has_value?(item)
      return false if item.group?
      @values.has_value?(item.key)
    end

    # Calculates the value of the given entry item given the current value store
    # and item default value.
    def item_value(item)
      return item_default_value(item) unless item_has_value?(item)
      val = @values.get_value(item.key)
      Settings.restore(val, item.type)
    end

    # Calculates the default value for an entry, handling callable defaults.
    def item_default_value(item)
      return nil if item.group? || item.default.nil?
      if item.default.respond_to?(:call)
        # Callable default, call in context of a root cursor, yielding our context (generally a
        # model instance) to the block.
        val = DslProxy.exec(Cursor.new(root, @values), @context, &(item.default))
        val = Settings.parse(val, item.type)
      else
        val = item.default
      end
      Settings.restore(val, item.type)
    end
    
    def eval_in_context(text) # :nodoc:
      proc = Proc.new {}
      binding = proc.binding
      eval(text, binding)
    end
    
  end
  
end