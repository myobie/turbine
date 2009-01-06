class Video < PostType
  fields :video_url, :description, :embed
  required :video_url
  primary :description
  
  def self.detect?(text)
    pairs, remainder = new.pull_pairs(text)
    video_count = pairs.reject { |pair| pair.keys.first != :video_url }
    video_count.length == 1
  end
end