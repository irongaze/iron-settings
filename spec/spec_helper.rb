# Set up activerecord & in-memory SQLite DB
require 'active_record'
require 'sqlite3'
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

# Uncomment to enable SQL logging during tests for debugging
# require 'logger'
# ActiveRecord::Base.logger = Logger.new(STDOUT)

# Require our library
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'iron', 'settings'))

# Run our migration to add DB value models to test DB
require_relative('../db/settings_migration')
SettingsMigration.migrate(:up)

# Run migration to create test model to use as settings owner
ActiveRecord::Migration.create_table :test_models do |t|
  t.string 'name'
end

# Create test model class
class TestModel < ActiveRecord::Base
  instance_settings do
    int('some_num', 5)
    int('no_default')
    group('some_group') do
      string('some_string')
      group('subgrouper') do
        symbol('yo', :baby)
      end
    end
  end
end

# Config RSpec options
RSpec.configure do |config|
  config.color = true
  config.add_formatter 'documentation'
  config.backtrace_exclusion_patterns = [/rspec/]
end

module SpecHelper
  
  # Helper to find sample file paths
  def self.sample_path(file)
    File.expand_path(File.join(File.dirname(__FILE__), 'samples', file))
  end
  
end
