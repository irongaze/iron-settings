# Dependencies
require 'tmpdir'
require 'fileutils'
require 'iron/extensions'
require 'iron/dsl'

# Top-level class with numerous helper methods for defining and handling
# our supported settings data types.
class Settings 

  # Registers a new data type for use in settings entries.  Pass a symbol
  # for the type, and a lambda that accepts an arbitrary value and either
  # parses it into a value of the required type or raises.
  #
  # For example, let's say we had a project that commonly had to assign
  # admin users (represented here by ActiveRecord models) on projects, tasks, etc.
  # We could create a :user data type that would seamlessly allow setting
  # and getting admin users as a native settings type:
  #
  #   Settings.register_type :user, 
  #     :parse => lambda {|val| val.is_a?(AdminUser) ? val.id : raise },
  #     :restore => lambda {|val| AdminUser.find_by_id(val) }
  #
  # Now we can use the user type in our settings definitions:
  #
  #   class Project < ActiveRecord::Base
  #     instance_settings do
  #       user('lead')
  #     end
  #   end
  #
  # With our settings defined, we can get and set admin users to that setting entry:
  #
  #   @project = Project.new(:name => 'Lazarus')
  #   @project.settings.lead = AdminUser.find_by_email('jim@example.com')
  #   @project.save
  #
  #   @project = Project.find_by_name('Lazarus')
  #   # Will use our :restore lambda to restore the id as a full AdminUser model
  #   @lead = @project.settings.lead
  #   # Will print 'jim@example.com'
  #   puts @lead.email
  #
  # If you do not define either the parse or restore lambdas, they will act as 
  # pass-throughs.  Also note that you do not need to handle nil values, which
  # will always parse to nil and restore to nil.
  def self.register_type(type, options = {})
    data_type_map[type] = {parse: options[:parse], restore: options[:restore]}
  end
  
  # Registers initial set of built-in data types
  def self.register_built_ins
    register_type(:int, parse: lambda {|val| val.is_a?(Fixnum) || (val.is_a?(String) && val.integer?) ? val.to_i : raise })
    register_type(:string, parse: lambda {|val| val.is_a?(String) ? val : raise })
    register_type(:symbol, parse: lambda {|val| val.is_a?(Symbol) ? val : raise })
    register_type(:bool, parse: lambda {|val| (val === true || val === false) ? val : raise })
    register_type(:var)
  end
  
  def self.data_type_map
    @data_type_map ||= {}
    @data_type_map
  end

  # Returns array of symbols for the supported data types for
  # settings entries.  You can add custom types using the #register_type 
  # method
  def self.data_types
    data_type_map.keys
  end
  
  # Returns the proper parser for a given type and mode (either :parse or :restore)
  def self.converter_for(type, mode)
    if type.to_s.ends_with?('_list')
      type = type.to_s.gsub('_list','').to_sym
    end

    hash = data_type_map[type]
    raise ArgumentError.new("Unknown settings data type [#{type.inspect}]") if hash.nil?
    hash[mode]
  end
  
  def self.parse(val, type)
    # Nil is always ok
    return nil if val.nil?
    
    # Check for lists
    parser = converter_for(type, :parse)
    if type.to_s.ends_with?('_list')
      # Gotta be an array, thanks
      raise ArgumentError.new("Must set #{type} settings to an array of values") unless val.is_a?(Array)

      # Parse 'em all
      return val if parser.nil?
      val.collect {|v| parser.call(v) } rescue raise ArgumentError.new("Values #{val.inspect} is not a valid #{type}")
    else
      # Single value
      return val if parser.nil?
      parser.call(val) rescue raise ArgumentError.new("Value [#{val.inspect}] is not a valid #{type}")
    end
  end

  def self.restore(val, type)
    # Nil restores to nil... always
    return nil if val.nil?
    
    # Check for lists
    restorer = converter_for(type, :restore)
    if type.to_s.ends_with?('_list')
      # Gotta be an array, thanks
      raise ArgumentError.new("Must set #{type} settings to an array of values") unless val.is_a?(Array)

      # Parse 'em all
      return val if restorer.nil?
      val.collect {|v| parser.call(v) } rescue raise ArgumentError.new("Unable to restore values #{val.inspect} to type #{type}")
    else
      # Single value
      return val if restorer.nil?
      restorer.call(val) rescue raise ArgumentError.new("Unable to restore value [#{val.inspect}] to type #{type}")
    end
  end

  def self.classes
    @classes ||= []
  end

  def self.default_timestamp_file(class_name)
    filename = class_name.gsub(/([a-z])([A-Z])/, '\1-\2').to_dashcase + '-settings.txt'
    defined?(Rails) ?
      File.join(RAILS_ROOT, 'tmp', filename) :
      File.join(Dir.tmpdir, filename)
  end

end

# Register our built-in types
Settings.register_built_ins

# Include required classes
require_relative 'settings/node'
require_relative 'settings/group'
require_relative 'settings/root'
require_relative 'settings/entry'
require_relative 'settings/builder'
require_relative 'settings/cursor'
require_relative 'settings/class_level'
require_relative 'settings/instance_level'
require_relative 'settings/value_store'
require_relative 'settings/static_store'
if defined?(ActiveRecord)
  require_relative 'settings/db_value'
  require_relative 'settings/db_store'
end

# Install our support at the correct scopes
Module.send(:include, Settings::ClassLevel)
Object.send(:include, Settings::InstanceLevel)

# Rails support here
if defined?(Rails)
  require_relative 'rake_loader'
end