require File.join(File.dirname(__FILE__), '../spec_helper.rb')

describe Quote do
  
  before do
    @good_quote = ">    This should be a quote."
    @good_quote_with_source = "Source: George Washington\n\n>    This is what he said."
    @good_quote_all_pairs = "Quote: Hello\nSource: Me"
    @bad_quote = "Rating: 4\nItem: Dyson\n\nThis should be the description."
    
    class Yellow; end
    Object.send(:remove_const, :Yellow)
  end
  
  should "detect a well-formed quote through markdown" do
    Quote.detect?(@good_quote).should.be.true
  end
  
  should "detect a well-formed quote with source" do
    Quote.detect?(@good_quote_with_source).should.be.true
  end
  
  should "detect a well-formed quote if it's all pairs" do
    Quote.detect?(@good_quote_all_pairs).should.be.true
  end
  
  should "not detect a malformed quote" do
    Quote.detect?(@bad_quote).should.be.false
  end
  
  should "autodetect a well-formed quote" do
    PostType.auto_detect(@good_quote).should.be.kind_of Quote
  end
  
end