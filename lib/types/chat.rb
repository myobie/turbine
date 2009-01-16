class Chat < PostType
  fields :transcript
  required :transcript
  
  # override commit_pairs to make chat transcripts form the Me: pairs stuff
  def commit_array(pairs_array)
    transcript = []
    
    pairs_array.each do |pairs_hash|
      
      pairs_hash.each do |key, value|
        
        unless self.class.allowed_fields_list.include?(key)
          transcript << { key => value }
        else
          set_attr(key, value)
        end
      end#of each
      
    end#of each
    
    set_attr(:transcript, transcript)
    
  end#of commit_pairs
  
  def self.detect?(text)
    has_one_or_more? text, :me
  end
end#of Chat