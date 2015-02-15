describe 'FeedlyToken' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a FeedlyToken entity' do
    FeedlyToken.entity_description.name.should == 'FeedlyToken'
  end
end
