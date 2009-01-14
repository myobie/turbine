class Review < PostType
  fields :rating, :item, :description
  required :rating, :item
  primary :description
  heading :item
  
  special :rating do |rating_content|
    rating_content.to_f
  end
  
  def self.detect?(text)
    pairs = TextImporter.new(self.class).import(text)
    required_count = pairs.reject { |pair| pair.keys.first != :rating && pair.keys.first != :item }
    required_count.length == 2
  end
end