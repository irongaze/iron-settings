describe Settings::ClassLevel do
  
  class SimpleTest
    class_settings do
      # General settings
      string('key', 'changeme')
      group('session') do
        string('secret')
        string('key') { '_' + key + '_session' }
        int('timeout')
      end
    end
  end
  
  class StaticTest 
    class_settings(:file => SpecHelper.sample_path('static-test')) do
      int('val1', 10)
      string('val2')
      group('group1') do
        symbol('val3')
      end
    end
  end
  
  it 'should be available in all Modules' do
    Module.should respond_to(:class_settings)
  end
  
  it 'should return a Builder instance' do
    class Bob ; end
    Bob.class_settings.should be_a(Settings::Builder)
  end
  
  it 'should not be available at instance level' do
    test = SimpleTest.new
    test.respond_to?(:settings).should be_false
  end
  
  # Basically an integration test
  it 'should load values from a file' do
    StaticTest.settings.val1.should == 200
    StaticTest.settings.val2.should == 'dogbone'
    StaticTest.settings.group1.val3.should == :a_symbol
  end
  
end