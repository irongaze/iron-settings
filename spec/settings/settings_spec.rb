describe Settings do

  it 'should return the list of installed data types' do
    Settings.data_types.should =~ [:int, :string, :bool, :symbol, :var]
  end

  it 'should correctly parse values that are of the right type' do
    # Valid values
    {
      :int => 5,
      :int => -1,
      :int => '10',
      :string => 'foo',
      :string => '',
      :string => nil,
      :symbol => :f123_foo,
      :bool => true,
      :bool => false,
      :bool => nil,
      :int_list => [5,2,-13,'0'],
      :string_list => [],
      :string_list => ['a', 'b'],
      :var => [1, :a, 'yo'],
      :var => Time.now
    }.each_pair do |type, val|
      expect { Settings.parse(val, type) }.to_not raise_error
    end
  end

  it 'should raise an error when parsing invalid values' do
    # Invalid values
    {
      :int => 5.0,
      :string => :symmish,
      :string => [],
      :symbol => 'stringish',
      :bool => 'true',
      :bool => 0,
      :bool => 1,
      :int_list => [0,:bob],
      :int_list => 12
    }.each_pair do |type, val|
      expect { Settings.parse(val, type) }.to raise_error(ArgumentError)
    end
  end
  
  it 'should pick a nice settings timestamp file path' do
    Settings.default_timestamp_file('SimpleTest').should == File.join(Dir.tmpdir, 'simple-test-settings.txt')
  end

  # Used below...
  class ClassLevelClass
    class_settings
  end
  
  it 'should provide a list of classes with class-level settings' do
    Settings.classes.should be_a(Array)
    Settings.classes.should include(ClassLevelClass)
  end
  
end