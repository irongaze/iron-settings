describe Settings::Builder do
  
  before do
    @root = Settings::Root.new
    @builder = Settings::Builder.new(@root)
  end
  
  it 'should add groups' do
    @builder.group('bob')
    group = @root.find_group('bob')
    group.should be_group
    group.key.should == 'bob'
  end
  
  it 'should return a builder after adding a group' do
    @builder.group('bob').should be_a(Settings::Builder)
  end
  
  it 'should add string entries' do
    @builder.string('foo')
    entry = @root.find_entry('foo')
    entry.should be_entry
    entry.key.should == 'foo'
    entry.type.should == :string
  end
  
  it 'should support all built-in data types' do
    Settings.data_types.each do |type|
      @builder.should respond_to(type)
    end
  end
  
  it 'should raise an error if defaults are not parseable' do
    expect { @builder.string('foo', 123) }.to raise_error(ArgumentError)
  end
  
  it 'should allow procs as defaults' do
    expect { @builder.string('yo', lambda { 'hi' }) }.to_not raise_error
  end
  
  it 'should reject key names that are invalid' do
    expect { @builder.int('bad.key') }.to raise_error
    expect { @builder.int('another-baddy') }.to raise_error
    expect { @builder.int('0isnotok') }.to raise_error
    expect { @builder.group('key.of.badness') }.to raise_error
  end
  
end