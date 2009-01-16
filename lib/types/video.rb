class Video < PostType
  fields :video_url, :title, :description, :embed
  required :video_url
  primary :description
  heading :title
  
  def self.detect?(text)
    has_required? text
  end
end