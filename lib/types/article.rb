class Article < PostType
  fields :title, :body, :category
  required :body
  primary :body
  heading :title
  
  def self.detect?(text)
    true # it can always be an article, so make this last in the preferred order
  end
end