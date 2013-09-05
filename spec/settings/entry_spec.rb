describe Settings::Entry do

  before do
    @settings = Settings::Root.new
    Settings::Builder.define(@settings) do 
      string('astring')
      int('someint', 25)
      symbol('procsym') { ('some_' + 'symbol').to_sym }
    end
  end

  it 'should know it is an entry' do
    entry = @settings.find_entry('astring')
    entry.should be_entry
    entry.should_not be_group
  end

  it 'should know its type' do
    @settings.find_entry('astring').type.should == :string
  end
  
  it 'should return undefined defaults as nil' do
    @settings.find_entry('astring').default.should be_nil
  end

  it 'should return simple defaults' do
    @settings.find_entry('someint').default.should == 25
  end
  
  it 'should save blocks as defaults' do
    @settings.find_entry('procsym').default.should be_a(Proc)
  end

end