describe Settings::Cursor do
  
  class CursorTest
    class_settings do
      int('val1', 5)
      int('val2')
      group('top') do
        group('middle') do
          group('bottom') do
            string('leaf')
            int('lamby') { val1 + 1 }
          end
        end
      end
      string('invalid_default', lambda { 5 })
    end
  end
  
  before do
    # Clear out temp data and reset to blank slate
    CursorTest.class_settings_reset!
  end
  
  it 'should traverse from group to group' do
    CursorTest.settings.top?.should be_true
    CursorTest.settings.top.middle?.should be_true
    CursorTest.settings.top.middle.bottom?.should be_true
  end
  
  it 'should test for value presence using interogator' do
    CursorTest.settings.val2?.should be_false
    CursorTest.settings.val2 100
    CursorTest.settings.val2?.should be_true
  end
  
  it 'should set via dsl-style and explicit setters' do
    CursorTest.settings.val1 = 5
    CursorTest.settings.val1.should == 5
    CursorTest.settings.val1 10
    CursorTest.settings.val1.should == 10
  end
  
  it 'should handle block-style setters' do
    CursorTest.settings.val1.should == 5
    CursorTest.settings do
      val1 6
      val2 0
    end
    CursorTest.settings.val1.should == 6
    CursorTest.settings.val2.should == 0
  end
  
  it 'should raise on setting an entry to an incorrect value type' do
    expect { CursorTest.settings.val1 = 'not an integer' }.to raise_error
  end
  
  it 'should raise an error on accessing an entry with a default proc that returns the wrong data type' do
    expect { CursorTest.settings.invalid_default }.to raise_error(ArgumentError)
  end
  
  it 'should support getting values via key strings' do
    CursorTest.settings['val1'].should == 5
    CursorTest.settings.top.middle.bottom.leaf = 'yo'
    CursorTest.settings['top.middle.bottom.leaf'].should == 'yo'
  end
  
  it 'should support setting values via key strings' do
    CursorTest.settings['top.middle.bottom.leaf'] = 'yo'
    CursorTest.settings.top.middle.bottom.leaf.should == 'yo'
  end

  it 'should return a cursor on getting a group\'s value using key access' do
    CursorTest.settings['top'].should be_a(Settings::Cursor)
  end
  
  it 'should return an array of all keys' do
    CursorTest.settings.entry_keys.should match_array([
      'val1',
      'val2',
      'top.middle.bottom.lamby',
      'top.middle.bottom.leaf',
      'invalid_default'
    ])
  end
  
  it 'should return keys relative to its bound group' do
    CursorTest.settings.top.middle.entry_keys.should match_array([
      'bottom.leaf', 'bottom.lamby'
    ])
  end
  
  it 'should eval lambda defaults in the context of the root cursor' do
    CursorTest.settings.top.middle.bottom.lamby.should == 6
  end
  
end