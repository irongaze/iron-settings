class SettingsMigration < ActiveRecord::Migration
  
  def change
    
    # To support db-backed settings, we need a table containing their values
    create_table :settings_values do |t|
      # Polymorphic ownership as "context"
      t.string  'context_type', :null => false
      t.integer 'context_id'

      # Full key, ie App.settings.foo.bar.some_value => 'foo.bar.some_value'
      t.string  'full_key', :null => false

      # Serialized value
      t.text    'value'
    end
    
    # In cases where we have a lot of db-backed settings, an index is a must!
    add_index :settings_values, ['context_type', 'context_id']
    
  end
  
end