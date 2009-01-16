require File.join(File.dirname(__FILE__), '../spec_helper.rb')

describe Chat do
  
  before do
    @good_chat = "You: Hello\nMe: Hello back at ya!\nYou: Wanna go eat\nYou: Somehwere\nMe: Yes!"
    @bad_chat = "Rating: 4\nItem: Dyson\n\nThis should be the description."
    
    class Yellow; end
    Object.send(:remove_const, :Yellow)
  end
  
  should "detect a well-formed chat" do
    Chat.detect?(@good_chat).should.be.true
  end
  
  should "not detect a malformed chat" do
    Chat.detect?(@bad_chat).should.be.false
  end
  
  should "autodetect a well-formed chat" do
    PostType.auto_detect(@good_chat).should.be.kind_of Chat
  end
  
end