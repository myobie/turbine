class Audio < PostType
  fields :audio_url, :title, :description, :embed
  required :audio_url
  primary :description
  heading :title
  
  def self.detect?(text)
    has_required? text
  end
end