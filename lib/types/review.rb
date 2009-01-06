class Review < PostType
  fields :rating, :item, :description
  required :rating, :item
  primary :description
  heading :item
  
  special :rating do |rating_content|
    rating_content.to_f
  end
  
  def self.detect?(text)
    one = new
    pairs, remainder = one.pull_pairs(text)
    one.content = ''
    one.eval_primary_field(remainder)
    pairs << { :item => one.content[:item] } unless one.content[:item].blank?
    
    required_count = pairs.reject { |pair| pair.keys.first != :rating && pair.keys.first != :item }
    required_count.length == 2
  end
end