describe Settings::ValueStore do
  
  it 'should require_reload? after initialization' do
    @store = Settings::ValueStore.new(Settings::Root.new)
    @store.should be_need_reload
  end
  
  it 'should always reload on reload == true' do
    @store = Settings::ValueStore.new(Settings::Root.new, :reload => true)
    @store.load
    @store.should be_need_reload
  end
  
  it 'should never reload on reload == false' do
    @store = Settings::ValueStore.new(Settings::Root.new, :reload => false)
    @store.load
    @store.should_not be_need_reload
  end
  
  it 'should reload after x seconds on reload == x' do
    @store = Settings::ValueStore.new(Settings::Root.new, :reload => 1)
    @store.load
    @store.should_not be_need_reload
    sleep 1
    @store.should be_need_reload
  end
  
  it 'should reload on file mtime change on reload == "some path"' do
    # Set test file path and create/update it
    path = File.join(Dir.tmpdir, 'settings-test.txt')
    FileUtils.touch(path)

    # Set our store to reload based on that file
    @store = Settings::ValueStore.new(Settings::Root.new, :reload => path)
    @store.load
    @store.should_not be_need_reload
    
    # Sleep a bit (needed due to OSX mtime resolution of 1 second... grr)
    sleep 1.1
    FileUtils.touch(path)
    @store.should be_need_reload
  end
  
  it 'should reload conditionally on reload == { some proc }' do
    # Set reload to a lambda referencing a locally scoped variable, toggle variable and
    # ensure need_reload? toggles as well...
    doit = true
    @store = Settings::ValueStore.new(Settings::Root.new, :reload => lambda { doit })
    @store.load
    @store.should be_need_reload
    doit = false
    @store.should_not be_need_reload
  end

end