describe Settings::DBValue do

  before do
    TestModel.delete_all
    Settings::DBValue.delete_all
  end
  
  it 'should save to the DB' do
    setting =  Settings::DBValue.new(:context => TestModel, :full_key => 'foo', :value => 'bar')
    setting.save!
  end
  
  it 'should load from the DB' do
    add_val(TestModel, 'unique', 'bar')
    setting = Settings::DBValue.find_by_full_key('unique')
    setting.should_not be_nil
    setting.value.should == 'bar'
  end

  it 'should find all owned values via scope' do
    model = TestModel.create!(:name => 'bobby')
    add_vals(TestModel, 
      'alpha' => 'a', 
      'beta' => 'b'
    )
    add_vals(model, 
      'do' => 'a', 
      're' => 'b',
      'mi' => 'c'
    )
    vals = Settings::DBValue.for_context(TestModel)
    vals.count.should == 2
    vals = Settings::DBValue.for_context(model)
    vals.count.should == 3
  end
  
  it 'should reload values in the same state as they are saved' do
    add_vals(TestModel,
      'string' => 'stringy',
      'int' => 501,
      'sym' => :bob
    )
    Settings::DBValue.find_by_full_key('string').value.should be_a(String)
    Settings::DBValue.find_by_full_key('int').value.should be_a(Fixnum)
    Settings::DBValue.find_by_full_key('sym').value.should be_a(Symbol)
  end
  
  def add_vals(context, val_map)
    val_map.each_pair do |k, v|
      add_val(context, k, v)
    end
  end
  
  def add_val(context, key, val)
    Settings::DBValue.create!(:context => context, :full_key => key, :value => val)
  end

end  
