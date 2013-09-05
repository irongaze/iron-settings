class Settings
  
  # Base class for our value stores.  Derived classes manage loading and saving
  # values in the value hash.
  class ValueStore
    
    def initialize(root, options = {})
      @root = root
      @options = options
      @loaded_on = nil
      @reload = options.delete(:reload) || false
      @values = {}
    end
    
    def need_reload?
      # Always reload at first chance, ie LOAD, duh
      return true if @loaded_on.nil?
      
      # Do the right thing
      case @reload
      when true then
        # Always reload each time #settings creates a new cursor
        true
        
      when false then
        # Never reload
        false
        
      when Proc then
        # Custom reload handler, reload on returning true
        @reload.call === true
        
      when Fixnum then
        # Reload after N seconds
        Time.now > @loaded_on + @reload.to_i
        
      when String then
        # Reload if file is modified
        mod_time = File.mtime(@reload) rescue nil
        mod_time.nil? || @loaded_on < mod_time
        
      else
        # Non-standard reload setting, must be handled in kids
        nil
      end
    end
    
    def reload_if_needed
      load if need_reload?
    end
    
    def load
      @loaded_on = Time.now
      @values = {}
    end
    
    def save
      # No saving for me, thanks
      return if read_only?
      
      # Update our timestamp on our cache reload file, if any
      if @reload.is_a?(String)
        FileUtils.touch(@reload)
      end
      
      # Remember when we were loaded for future use
      @loaded_on = Time.now
    end
    
    def has_value?(key)
      @values.has_key?(key)
    end
    
    def get_value(key)
      @values[key]
    end
    
    def set_value(key, value)
      @values[key] = value
    end
    
    def read_only?
      false
    end
    
  end
  
end