describe 'PinboardToken' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a PinboardToken entity' do
    PinboardToken.entity_description.name.should == 'PinboardToken'
  end
end
