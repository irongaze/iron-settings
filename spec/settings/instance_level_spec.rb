describe Settings::InstanceLevel do

  before do
    Settings::DBValue.delete_all
    @model = TestModel.new(:name => 'test')
  end
  
  it 'should be available in all Objects' do
    Object.should respond_to(:instance_settings)
  end
  
  it 'should return a Builder instance' do
    class Bob ; end
    Bob.instance_settings.should be_a(Settings::Builder)
  end
  
  it 'should not be available at class level' do
    class Tim
      instance_settings do
        int('foo')
      end
    end
    Tim.respond_to?(:settings).should be_false
  end
  
  it 'should allow setting values for a specific model' do
    @model.settings.some_num.should == 5
    @model.settings.some_num = 10
    @model.settings.some_num.should == 10
  end
  
  it 'should save pending settings values to the database when the model is saved' do
    Settings::DBValue.find_by_full_key('some_num').should be_nil      # Sanity check - not yet in DB
    @model.settings.some_num = 20
    Settings::DBValue.find_by_full_key('some_num').should be_nil      # Setting value should not save
    @model.save
    Settings::DBValue.find_by_full_key('some_num').should_not be_nil  # Saving model SHOULD
    
    # Reset model state and verify settings load correct value
    @model.settings_reset!
    @model.settings.some_num.should == 20
  end
  
end