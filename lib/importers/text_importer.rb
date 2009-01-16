class TextImporter
  
  attr_accessor :remainder, :result, :type
  
  def initialize(type)
    @type = type
    @result = []
    @remainder = ''
    @primary = nil
    @heading = nil
  end
  
  def import(text)
    pull_pairs(text)
    eval_primary_field
    
    @result
  end

  def pull_pairs(text)
    last_pair_found = false
  
    text.each_line do |line|
    
      unless last_pair_found
        possible_pair = detect_pair(line)
        if possible_pair and possible_pair.captures.length == 2
          key = possible_pair.captures[0].downcase.to_sym
          value = possible_pair.captures[1]
          number_of_lines = value.count("\n") + 1
          @result << { key => value.strip }
          next # don't put this in the remainder
        else
          last_pair_found = true
        end#of if
      end
    
      @remainder << line # keep this around, it might be useful
    end#of each_line
    
    @remainder.strip!
  end#of parse_pairs

  def detect_pair(line)
    line.strip.match(/(^[A-Za-z0-9_]+):(.+)/)
  end
  
  def eval_primary_field
    unless @remainder.blank? || @type.primary_field.blank?
      @primary = @remainder
      
      eval_heading_field unless @type.heading_field.blank?
      
      save_primary
      save_heading
    end
  end

  def eval_heading_field
    # check for an <h1> at the beginning of the primary and if it's there pull it out for the heading
    possible_hone = remainder.match(/(.+)\n=+\n*|^# (.+)\w*\n*/)
    
    caps = []
    caps = possible_hone.captures.compact unless possible_hone.blank?
    
    # if it's there, then parse it out of the remainder
    if !possible_hone.blank? and caps.length == 1
      @heading = caps.first
      
      ### Remove heading from text
      @primary = @primary.
        strip.
        gsub(/^#{possible_hone.captures.first}\n=+\n*/, '').
        gsub(/^# #{possible_hone.captures.first}\w*\n*/, '').
        strip
    end#of if
  end#of eval_heading_field
  
  def save_primary
    unless @primary.blank?
      # see if a pair already exists for the primary_field
      existing_primary = @result.select { |pair| pair.keys.first == @type.primary_field }
      existing_primary = existing_primary.first
    
      # get rid of the primary_field if it's already there
      @result.delete(existing_primary)
    
      # if there was any existing, prepend it to remanding
      @primary = existing_primary.to_s + @primary unless existing_primary.blank?
    
      # append a new pair for the fields
      @result << { @type.primary_field => @primary } unless @primary.blank?
    end
  end
  
  def save_heading
    unless @heading.blank?
      # see if a pair already exists for the primary_field
      existing_heading = @result.select { |pair| pair.keys.first == @type.heading_field }
      existing_heading = existing_heading.first
    
      # get rid of the primary_field if it's already there
      @result.delete(existing_heading)
    
      # if there was any existing, prepend it to remanding
      @heading = existing_heading.to_s + @heading unless existing_heading.blank?
    
      # append a new pair for the fields
      @result << { @type.heading_field => @heading } unless @heading.blank?
    end
  end
  
end