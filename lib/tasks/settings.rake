namespace :settings do
  
  desc "Install components required for integration of the iron-settings gem with your Rails app"
  task :install => :environment do
    spec = Gem::Specification.find_by_name("iron-settings")
    gem_root = spec.gem_dir
    
    # Our destination directory
    dir = File.join(Rails.root, 'db/migrate')
    
    # Our source migration files
    src = File.join(gem_root, 'db/settings_migration.rb')
    filename = Time.now.strftime('%Y%m%d%H%M%S') + '_' + File.basename(src)
    dest = File.join(dir, filename)
    
    puts ''
    puts "Installing settings migration(s) into #{dir} as:"
    puts "  #{filename}"
    puts ''
    
    if Dir.glob(File.join(dir, '*_' + File.basename(src))).empty?
      FileUtils.cp(src, dest)
      if File.exist?(dest)
        puts "Migration installed successfully, please remember to run rake db:migrate to complete the installation"
      else
        puts "ERROR: migration file not created"
        puts ''
        puts "You may need to manually install the migration located here:"
        puts "  #{src}"
      end
    else
      puts "Migration already installed - skipping!"
    end
    
    puts ''
  end
  
  desc "Display all possible settings and their current values"
  task :list => :environment do
    Settings.classes.each do |klass|
      puts "\n#{klass.name} Settings"
      puts "----------------"
      settings = klass.settings
      groups = [settings.root]
      until groups.empty?
        # Get the next group to work on
        group = groups.shift
        
        # Run each entry and display its current value
        group.entries(false).sort_by(&:key).each do |entry|
          info = entry.key + ' = ' + settings.item_value(entry).inspect + " (#{entry.type})"
          unless klass.settings.item_has_value?(entry)
            info = "\e[1;30m" + info + "\e[0;9m"
          end
          puts info
        end
        
        # Add in sub-groups for next iteration, depth-first-wise
        groups = group.groups(false).sort_by(&:key) + groups
      end
    end
    puts ""
  end

end
