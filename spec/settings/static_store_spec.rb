describe Settings::StaticStore do

  class StaticStoreTest
    class_settings do
      int('val1')
      string('val2')
      group('group1') do
        symbol('val3')
      end
    end
  end
  
  before do
    @store = Settings::StaticStore.new(Settings::Root.new)
  end
  
  it 'should save values' do
    @store.set_value('foo.bar', 27)
    @store.get_value('foo.bar').should == 27
  end
  
  it 'should accept paths' do
    store = Settings::StaticStore.new(StaticStoreTest.settings.root, :file => SpecHelper.sample_path('static-test'))
    store.paths.count.should == 1
    store.paths.first.should == SpecHelper.sample_path('static-test')
  end
  
  it 'should need a reload on first init with one or more paths' do
    store = Settings::StaticStore.new(StaticStoreTest.settings.root, :file => SpecHelper.sample_path('static-test'))
    store.should be_need_reload
  end
  
  it 'should ignore missing files' do
    store = Settings::StaticStore.new(StaticStoreTest.settings.root, :file => '/tmp/made-up')
    store.load
    store.get_value('val1').should be_nil
  end
  
  it 'should load all paths in order' do
    store = Settings::StaticStore.new(StaticStoreTest.settings.root, :files => [SpecHelper.sample_path('static-test'), SpecHelper.sample_path('static-test-2')])
    store.load
    store.get_value('val1').should == 205
    store.get_value('val2').should == 'dogbone'
  end
  
end