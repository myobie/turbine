class Audio < PostType
  fields :audio_url, :description, :embed
  required :audio_url
  primary :description
  
  def self.detect?(text)
    pairs, remainder = new.pull_pairs(text)
    audio_count = pairs.reject { |pair| pair.keys.first != :audio_url }
    audio_count.length == 1
  end
end