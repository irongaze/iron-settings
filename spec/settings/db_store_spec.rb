describe Settings::DBStore do
  
  before do
    @store = Settings::DBStore.new(Settings::Root.new, Settings)
  end
  
  it 'should save values' do
    @store.set_value('tim', :f00)
    @store.get_value('tim').should == :f00
  end
  
end