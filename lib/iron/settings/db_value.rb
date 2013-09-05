# Stores a given setting entry's value in the database
class Settings::DBValue < ActiveRecord::Base

  # Use a non-standard table name
  self.table_name = 'settings_values'

  # Scopes for our values
  scope :for_context, lambda {|context| 
    if context.is_a?(Module)
      klass = context
      id = nil
    else
      klass = context.class
      id = context.id
    end
    where(:context_type => klass.to_s, :context_id => id) 
  }
  
  # We serialize our values...
  serialize :value
  
  # Set our context
  def context=(context)
    if context.is_a?(ActiveRecord::Base)
      self.context_type = context.class.name
      self.context_id = context.id
    else
      self.context_type = context.to_s
      self.context_id = nil
    end
  end

end