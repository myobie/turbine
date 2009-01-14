require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe PostType do
  
  before do
    class Yellow; end
    Object.send(:remove_const, :Yellow)
  end
  
  should "have empty content when new" do
    PostType.new.content.should == nil
  end
  
  should "have a preferred order array" do
    PostType.preferred_order.should == [Video, Audio, Photo, Chat, Review, Link, Quote, Article]
  end
  
  should "set fields" do
    class Yellow < PostType
      fields :one, :two
    end
    
    Yellow.fields_list.should == [:one, :two]
  end
  
  should "set allowed fields" do
    class Yellow < PostType
      fields :one
      allow :anyone, :noone
    end
    
    Yellow.allowed_fields_list.should == [Yellow::DEFAULT_FIELDS, :one, :anyone, :noone].flatten
  end
  
  should "set required fields" do
    class Yellow < PostType
      fields :one, :two, :three
      required :one, :two
    end
    
    Yellow.required_fields_list.should == [:one, :two] 
  end
  
  should "set primary field" do
    class Yellow < PostType
      fields :one, :two
      primary :one
    end
    
    Yellow.primary_field.should == :one
  end
  
  # should use primary field
  # should make primary field markdown automatically
  
  should "set heading field" do
    class Yellow < PostType
      fields :one, :two
      heading :one
    end
    
    Yellow.heading_field.should == :one
  end
  
  should "use heading field" do
    class Yellow < PostType
      fields :one, :two
      primary :one
      heading :two
    end
    
    y = Yellow.new "Hello Two
=========

This will be in One."
    
    y.get_attr(:one).should == "<p>This will be in One.</p>"
    y.get_attr(:two).should == "Hello Two"
  end
  
  should "set special values" do
    class Yellow < PostType
      fields :plus_one, :two
      
      special :plus_one do |field_value|
        field_value + 1
      end
    end
    
    Yellow.specials_blocks[:plus_one].should.not.be.blank?
  end
  
  should "use special values" do
    class Yellow < PostType
      fields :one, :two
      
      special :one do |field_value|
        field_value.to_i + 1
      end
    end
    
    y = Yellow.new "One: 2\n\nhello"
    
    y.get_attr(:one).should == 3
  end
  
  should "set default values" do
    class Yellow < PostType
      fields :one, :two
      
      default(:one) { 1 }
    end
    
    Yellow.defaults_blocks[:one].call.should == 1
  end
  
  should "use default values" do
    class Yellow < PostType
      fields :one, :two
      
      default :two do
        2
      end
    end
    
    y = Yellow.new 'hello'
    
    y.get_attr(:two).should == 2
  end
  
  should "use markdown fields" do
    class Yellow < PostType
      fields :one, :two
      markdown :two
    end
    
    Yellow.markdown_fields.should == [:two]
    Yellow.allowed_fields_list.should == [Yellow::DEFAULT_FIELDS, :one, :two, :two_html].flatten
  end
  
  should "use markdown fields" do
    class Yellow < PostType
      fields :one, :two
      markdown :two
    end
    
    y = Yellow.new "Two: *hahaha*"
    
    y.get_attr(:two).should == "<p><em>hahaha</em></p>"
  end
  
  should "allow setting and getting of an attribute of the content" do
    class Yellow < PostType; end
    y = Yellow.new 'stuff'
    y.set_attr(:first, 'woo hoo')
    y.get_attr(:first).should == 'woo hoo'
  end
  
  should "not keep empty attributes" do 
    class Yellow < PostType
      fields :one
      primary :one
    end
    
    y = Yellow.new 'stuff'
    y.set_attr(:one, '')
    y.get_attr(:one).should.be.nil
  end
  
  # should auto_detect ?
  # should save ?
  # should generate slug
  
end