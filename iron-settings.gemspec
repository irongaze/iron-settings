
Gem::Specification.new do |s|
  # Project attributes
  s.name        = "iron-settings"
  s.summary     = "Application settings in code and database"
  s.description = "Allows defining settings with defaults to be overridden in code or via database values.  Built to work well with Rails models."

  # Post-install message
  # s.post_install_message = "Thanks for installing!"

  # Additional dependencies
  s.add_dependency "iron-extensions", "~> 1.2"
  s.add_dependency "iron-dsl", "~> 1.0"

  # Include all gem files that should be packaged
  s.files = Dir[
    "lib/**/*",
    "bin/*",
    "db/*",
    "spec/**/*",
    "LICENSE",
    "*.txt",
    "*.rdoc",
    ".rspec"
  ]
  # Prune out files we don't want to include
  s.files.reject! do |p| 
    ['.tmproj', 'TODO.txt'].detect {|test| p.include?(test)}
  end
  
  # Meta-info
  s.version     = File.read('version.txt').strip
  s.authors     = ["Rob Morris"]
  s.email       = ["rob@irongaze.com"]
  s.homepage    = "http://irongaze.com"
  
  # Boilerplate
  s.platform    = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.executables = Dir["bin/*"].collect {|p| File.basename(p)}
  s.add_development_dependency "rspec", "~> 2.6"
  s.required_ruby_version = '>= 1.9.2'
  s.license     = 'MIT'
end