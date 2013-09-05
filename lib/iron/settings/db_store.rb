class Settings # :nodoc:
  
  # Implements database-backed value storage for dynamic settings.  This value store is appropriate for both
  # class-level and instance-level settings storage.  This store takes no special options on creation, however
  # it is critical that the proper :reload option be set for your use-case.  
  #
  # For class-level settings, the proper option (and default) will often be to use a 
  # synchronization file by specifying :reload => '<some path>' during 
  # initialization.  This will cause the value store to touch the given file on saving changes, and
  # reload values when the timestamp on the file is newer than the last reload.
  #
  # For example, in Rails (with long-running, multi-instance operations), this will allow you to have
  # your settings loaded once on load, then once per instance when changes are saved to the database.
  #
  # For instance-level settings, the proper value is often :reload => false, as the values will
  # be loaded on initilization of the instance, then thrown away with the instance.  This will be 
  # ideal for Models in Rails, for example.  If you have long-running instances that need reloads,
  # you can use a shared timestamp as above, causing *all* instances to reload when any instance
  # changes (feasible for a small number of instances or when settings do not change frequently), or
  # you can set a timeout in seconds using :reload => <num seconds> to cause instances to reload
  # after that time has elapsed.
  class DBStore < Settings::ValueStore

    def initialize(root, context, options = {})
      options = {
        :reload => false
      }.merge(options)
      @context = context

      # Let our base class at it
      super(root, options)
    end

    def load
      super
      
      # Load up the values from DB, store in internal values hash by full key
      Settings::DBValue.for_context(@context).each do |val|
        @values[val.full_key] = val.value
      end
    end

    def save
      # Clear any old settings
      Settings::DBValue.for_context(@context).delete_all
      
      # Create new settings
      @values.each_pair do |key, val|
        Settings::DBValue.create(context: @context, full_key: key, value: val)
      end
      
      super
    end
    
  end
  
end