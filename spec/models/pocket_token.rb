describe 'PocketToken' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a PocketToken entity' do
    PocketToken.entity_description.name.should == 'PocketToken'
  end
end
