class Settings
  
  # Provides in-memory static (aka file and code-based) settings, suitable for class-level settings 
  # for gems, frameworks, command-line tools, etc.
  class StaticStore < Settings::ValueStore

    attr_accessor :paths

    def initialize(root, options = {})
      file = options.delete(:file)
      files = options.delete(:files)
      @secure = !(options.delete(:secure) === false)
      @ignore_missing = !(options.delete(:ignore_missing) === false)
      super(root, options)
      
      @paths = []
      @paths << file if file
      @paths += files || []
      
      @modified_time = @paths.convert_to_hash(nil)
    end

    # True on our reload settings matching (see ValueStore#need_reload?), or if
    # any of our settings files have been modified since our last load.
    def need_reload?
      return true if super
      @modified_time.any? do |path, time| 
        File.exist?(path) && File.mtime(path) != time 
      end
    end
    
    # We don't support saving our current state, hence "static" :-)
    def read_only?
      true
    end

    # Load our values from the file(s) specified during creation, in order,
    # respecting the :secure option to only load safe settings files
    # if so specified.
    def load
      super
      @paths.each {|p| load_file(p) }
    end

    # Loads a single settings file, verifying its existence, ownership/security, etc.
    # 
    def load_file(path)
      # Ensure we have the file, if so required
      raise RuntimeError.new("Missing settings file #{path} - this file is required") unless @ignore_missing || File.exists?(path)

      # Read in the settings file
      verify_file_security(path)
      text = File.read(path) rescue ''
      return if text.blank?
      
      # Create a cursor, and eval the file's contents in the cursor's context
      cursor = Settings::Cursor.new(@root, self)
      cursor.eval_in_context(text)

      # Remember our modified time for future checking
      @modified_time[path] = File.mtime(path)
    end
    
    def save_file(path)
      @modified_time[path] = File.mtime(path)
      raise 'Unimplemented!'
    end
    
    # Implements :secure test for settings files.  Verifies that the specified file is:
    #
    # * Owned by the same user ID that is running the current process
    # * Not world-writable
    #
    def verify_file_security(path)
      # Not requiring security?  File doesn't exist?  Then everything is fine...
      return unless (File.exists?(path) && @secure)
      
      stat = File::Stat.new(path)
      raise RuntimeError.new("Cannot load settings file #{path} - file must be owned by the user this program is running as (UID #{Process.uid})") unless stat.owned?
      raise RuntimeError.new("Cannot load settings file #{path} - file cannot be world-writable") if stat.world_writable?
    end
    
  end
  
end