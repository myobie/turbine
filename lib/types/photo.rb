class Photo < PostType
  fields :photo_url, :caption, :embed
  required :photo_url
  primary :caption
  
  def self.detect?(text)
    pairs, remainder = new.pull_pairs(text)
    photo_count = pairs.reject { |pair| pair.keys.first != :photo_url }
    photo_count.length == 1
  end
end