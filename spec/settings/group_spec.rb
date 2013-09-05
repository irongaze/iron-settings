describe Settings::Group do

  before do
    @root = Settings::Root.new
  end
  
  it 'should know it is a group' do
    @root.add_group('sub')
    group = @root.find_group('sub')
    group.should be_group
    group.should_not be_entry
  end

  it 'should know its full key' do
    fun = @root.add_group('fun')
    times = fun.add_group('times')
    fun.key.should == 'fun'
    times.key.should == 'fun.times'
  end
  
  it 'should find child groups' do
    @root.add_group('sub')
    group = @root.find_group('sub')
    group.should be_a(Settings::Group)
    group.key.should == 'sub'
  end
  
  it 'should find child entries' do
    @root.add_entry('some_value', :string)
    entry = @root.find_entry('some_value')
    entry.should be_a(Settings::Entry)
    entry.key.should == 'some_value'
  end

end