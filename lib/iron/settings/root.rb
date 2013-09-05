
class Settings

  # Root of a settings definition tree - contains a set of groups and entries
  class Root < Settings::Group
  
    # Construct ourselves
    def initialize
      # We're a group...
      super(nil, '')
    end
  
  end

end