# Defines a Railtie to inject our rake tasks into the Rails rake environment
class SettingsRailtie < Rails::Railtie
  rake_tasks do
    Dir[File.join(File.dirname(__FILE__),'../tasks/*.rake')].each { |f| load f }
  end
end