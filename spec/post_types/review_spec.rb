require File.join(File.dirname(__FILE__), '../spec_helper.rb')

describe Review do
  
  before do
    @good_review = "Rating: 4\nItem: Dyson\n\nThis should be the description."
    @bad_review = "You: Hello\nMe: Hello back at ya!\nYou: Wanna go eat\nYou: Somehwere\nMe: Yes!"
    @almost_good_review = "Rating: 4\n\nThis should be the description."
    
    class Yellow; end
    Object.send(:remove_const, :Yellow)
  end
  
  should "detect a well-formed review" do
    Review.detect?(@good_review).should.be.true
  end
  
  should "not detect a malformed review" do
    Review.detect?(@bad_review).should.be.false
  end
  
  should "not detect an almost good review" do
    Review.detect?(@almost_good_review).should.be.false
  end
  
  should "autodetect a well-formed review" do
    PostType.auto_detect(@good_review).should.be.kind_of Review
  end
  
end