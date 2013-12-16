class Settings #:nodoc:
  
  # Class-level settings can be either static (file/code-based) or dynamic (db-based) depending
  # on your needs.  Static settings will work well for gem configuration, command-line tools,
  # etc. while dynamic settings might be useful for a CMS or other web-based tool that needs
  # to support user editing of settings values on-the-fly.
  module ClassLevel

    module ClassMethods
    
      # Access the class-level settings values for this class, returns
      # a Settings::Cursor to read/write, pointed at the root of the 
      # settings definition for this class.
      #
      # Optionally accepts a block
      # for mass assignment using DSL setters, eg:
      #
      #    Foo.settings do
      #      some_group.some_entry 'some value'
      #      some_other_entry 250
      #    end
      def settings(&block)
        @settings_values.reload_if_needed
        cursor = Settings::Cursor.new(@settings_class_root, @settings_values)
        DslProxy::exec(cursor, &block) if block
        cursor
      end
    
      # Reset state to default values only - useful in testing
      def class_settings_reset!
        @settings_values = @settings_class_options[:store] == :static ? 
          Settings::StaticStore.new(@settings_class_root, @settings_class_options) :
          Settings::DbStore.new(@settings_class_root, @settings_class_options)
      end

      # Force a settings reload (from db or file(s) depending on settings) regardless
      # of need to reload automatically.  Useful for testing, but not generally needed in production use
      def reload_settings
        @settings_values.load
      end

    end
  
    # Define the class-level settings for a given class.  Supported options include:
    #
    #   :store => :static | :dynamic - how to load and (potentially) save settings values, defaults to :static
    #
    # Static mode options:
    #
    #   :file => '/path/to/file' - provides a single file to load when using the static settings store
    #   :files => ['/path1', '/path2'] - same as :file, but allows multiple files to be loaded in order
    #
    # Reload timing (primarily intended for use with :db mode):
    #
    #   :reload => <when> - when and if to reload from file/db, with <when> as one of:
    #      true - on every access to #settings
    #      false - only do initial load, never reload
    #      '/path/to/file' - file to test for modified timestamp changes, reload if file timestamp is after latest load
    #      <num seconds> - after N seconds since last load
    #      lambda { <true to reload> } - custom lambda to execute to check for reload, reloads on returned true value
    #
    # Any options passed on subsequent calls to #class_settings will be ignored.
    #
    # A passed block will be evaluated in the context of a Settings::Builder instance
    # that can be used to define groups and entries.
    #
    # Example:
    #
    #    class Site
    #      class_settings(:file => File.join(RAILS_ROOT, 'config/site-settings.rb')) do
    #        string('name')
    #        group('security') do
    #          bool('force-ssl', false)
    #          string('secret-key')
    #        end
    #      end
    #    end
    #
    # The above would set up Site.settings.name, Site.settings.security.force_ssl, etc, with an optional settings
    # file located at $RAILS_ROOT/config/site-settings.rb
    def class_settings(options = {}, &block)
      unless @settings_class_root
        # Set up our root group and options
        @settings_class_root = Settings::Root.new()
        options = {
          :store => :static
        }.merge(options)
        
        # Set our default reload timing
        if options[:reload].nil?
          if options[:store] == :static
            # Static settings generally don't need reloading
            options[:reload] = false
          else
            # For dynamic, db-backed settings at the class level, we use
            # file modified reload timing by default
            options[:reload] = Settings.default_timestamp_file(self.name)
          end
        end
        
        # Save off our options
        @settings_class_options = options
        
        # Add this class to the settings registry
        Settings.classes << self

        # Add in support for settings for this class
        extend ClassMethods
        
        # Create our value store
        class_settings_reset!
      end
    
      # Create a builder and do the right thing based on passed args
      builder = Settings::Builder.new(@settings_class_root)
      builder.define(&block) if block
      builder
    end
    
  end
  
end