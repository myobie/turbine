class Photo < PostType
  fields :photo_url, :caption, :embed
  required :photo_url
  primary :caption
  
  def self.detect?(text)
    has_required? text
  end
end