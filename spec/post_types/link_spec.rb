require File.join(File.dirname(__FILE__), '../spec_helper.rb')

describe Link do
  
  before do
    @good_link = "URL: google.com\n\nThis should be the description."
    @bad_link = "Rating: 4\nItem: Dyson\n\nThis should be the description."
    
    class Yellow; end
    Object.send(:remove_const, :Yellow)
  end
  
  should "detect a well-formed link" do
    Link.detect?(@good_link).should.be.true
  end
  
  should "not detect a malformed link" do
    Link.detect?(@bad_link).should.be.false
  end
  
  should "autodetect a well-formed link" do
    PostType.auto_detect(@good_link).should.be.kind_of Link
  end
  
end