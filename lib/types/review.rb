class Review < PostType
  fields :rating, :item, :description
  required :rating, :item
  primary :description
  heading :item
  
  special :rating do |rating_content|
    rating_content.to_f
  end
  
  def self.detect?(text)
    has_required? text
  end
end