class Settings

  module InstanceLevel

    # Will be bound to Object, provides support for defining settings structure + defaults
    # at the class level for use in instances of that class.  Defaults to database-backed
    # dynamic storage with a 10 second reload.  Requires that ActiveRecord be required
    # prior to requiring this gem.
    module ClassMethods

      def instance_settings(options = {}, &block)
        unless @settings_instance_root
          @settings_instance_root = Settings::Root.new()
          @options = {
            :store => :dynamic
          }.merge(options)
        end
      
        # Set our default reload timing
        if options[:reload].nil?
          if options[:store] == :static
            # Static settings generally don't need reloading
            options[:reload] = false
          else
            # For dynamic, db-backed settings at the instance level, we use
            # a 10 second timeout by default
            options[:reload] = 10
          end
        end

        # Save off our options
        @settings_instance_options = options
      
        # This class now need settings support at the instance level
        include InstanceMethods

        # Add our save hook if the class is an ActiveRecord model
        if defined?(ActiveRecord) && self < ActiveRecord::Base
          after_save :settings_save!
        end
      
        # Construct a builder and do the right thing
        builder = Settings::Builder.new(@settings_instance_root)
        builder.define(&block) if block
        builder
      end
    
      def settings_instance_options
        @settings_instance_options
      end
    
      def settings_instance_root
        @settings_instance_root
      end
    
    end

    # Set of methods that all instances with instance_settings set will share
    module InstanceMethods

      # Access settings at instance level
      def settings(&block)
        # Ensure we have a value store
        unless @settings_values 
          settings_reset!
        end

        # Set up for use, create a cursor to read/write, and we're good to go
        @settings_values.reload_if_needed
        cursor = Settings::Cursor.new(self.class.settings_instance_root, @settings_values, self)
        DslProxy::exec(cursor, &block) if block
        cursor
      end
  
      def settings_save!
        @settings_values.save if @settings_values
      end
  
      # Throw out any unsaved changes
      def settings_reset!
        # Create our value store
        opts = self.class.settings_instance_options
        @settings_values = opts[:store] == :static ? 
          Settings::StaticStore.new(self.class.settings_instance_root, opts) :
          Settings::DBStore.new(self.class.settings_instance_root, self, opts)
      end

    end

    # Install hooks
    def self.included(base)
      # Add our class methods
      base.extend(ClassMethods)
    end

  end
  
end