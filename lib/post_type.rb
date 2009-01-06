require 'rdiscount' # markdown
require 'nokogiri'
require 'uuidtools'

class PostType
  extend ClassLevelInheritableAttributes
  include Extlib::Hook
  
  DEFAULT_FIELDS = [:published_at, :status, :slug, :trackbacks, :type, :tags]
  
  # vars to inherit down
  cattr_inheritable :fields_list, :allowed_fields_list, :required_fields_list, :primary_field, :heading_field, 
                    :specials_blocks, :defaults_blocks, :only_declared_fields, :always_use_uuid,
                    :truncate_slugs, :markdown_fields
  
  # defaults for class instance inheritable vars
  @fields_list = []
  @allowed_fields_list = []
  @required_fields_list = []
  @primary_field = nil
  @heading_field = nil
  @specials_blocks = {}
  @defaults_blocks = {}
  @only_declared_fields = true
  @always_use_uuid = false
  @truncate_slugs = true
  @markdown_fields = []
  
  
  ### cattr_accessor
  @@preferred_order = []
  
  def self.preferred_order
    @@preferred_order
  end
  def self.preferred_order=(new_order)
    @@preferred_order = new_order
  end
  ### cattr_accessor
  
  attr_accessor :content # where everything is stored
  
  ### basic setup methods for types of posts
  def self.fields(*list) # NOTE: this is a replacing function, not addititve like the others
    self.fields_list = list.make_attrs
    self.allowed_fields_list = [DEFAULT_FIELDS, list.make_attrs].flatten.uniq
  end
  
  def self.allow_field(field)
    self.allowed_fields_list = [self.allowed_fields_list, field.make_attr].flatten.uniq
  end
  
  def self.required(*list)
    self.required_fields_list = [
                                  self.required_fields_list,
                                  list.make_attrs.reject { |l| !fields_list.include? l }
                                ].flatten.uniq
  end
  
  def self.primary(field)
    field = field.make_attr
    
    if fields_list.include? field
      self.primary_field = field
      markdown field # primary is a markdown field by default
    end
  end
  
  def self.heading(field)
    field = field.make_attr
    self.heading_field = field if fields_list.include? field
  end
  
  def self.special(field, &block)
    field = field.make_attr
    self.specials_blocks[field.make_attr] = block if fields_list.include? field
  end
  
  def self.default(field, &block)
    field = field.make_attr
    self.defaults_blocks[field.make_attr] = block if fields_list.include? field
  end
  
  def self.dynamic(field, &block)
    field = field.make_attr
    self.dynamic_blocks[field] = block
    allow_field(field)
  end
  
  def self.markdown(*list)
    self.markdown_fields =  [
                              self.markdown_fields,
                              list.make_attrs.reject { |l| !fields_list.include? l }
                            ].flatten.uniq
                            
    self.allowed_fields_list = [
                                  self.allowed_fields_list, 
                                  self.markdown_fields.collect { |m| m.html }
                                ].flatten.uniq
  end
  
  def set_attr(key, value)
    key = key.make_attr
    
    unless value.blank?
      @content[key] = value
      
      if self.class.markdown_fields.include?(key)
        markdown = Markdown.new @content[key].strip
        @content[key.html] = markdown.to_html.strip
      else
        @content.delete(key.html)
      end
    else
      @content.delete(key)
      @content.delete(key.html)
    end
  end
  
  def set_default(key, value)
    set_attr(key, value) if blank_attr?(key)
  end
  
  def blank_attr?(key)
    get_attr(key).blank?
  end
  
  alias :get_attr? :blank_attr?
  
  def get_attr(key, html = true)
    key = key.make_attr
    
    if html && self.class.markdown_fields.include?(key)
      @content[key.html]
    else
      @content[key]
    end
  end
  
  def delete_attr(key)
    set_attr(key.make_attr, nil)
  end
  
  alias :remove_attr :delete_attr
  alias :del_attr :delete_attr
  
  # can be overriden to provide auto detection of type from a block of text
  def self.detect?(text)
    false
  end
  
  # def self.has_keys?(text, *keys)
  #   count = keys.length
  #   
  #   one = new
  #   pairs, remainder = one.pull_pairs(text)
  #   
  #   unless one.class.primary_field.blank?
  #     one.content = ''
  #     one.eval_primary_field(remainder)
  #     pairs << { :"#{one.class.heading_field}" => one.content[:"#{one.class.heading_field}"] } unless one.content[:"#{one.class.heading_field}"].blank?
  #   end
  #   
  #   required_count = pairs.reject { |pair| 
  #     answers = []
  #     
  #     keys.each do |key| 
  #       answers << pair.keys.first != key
  #     end
  #     
  #     answers.all?
  #   }
  #   
  #   required_count.length == count
  # end
  
  # runs through the list of children looking for one that will work
  def self.auto_detect(text)
    list = self.preferred_order.blank? ? @all_children : self.preferred_order
    
    list.each { |l| return l.new(text) if l.detect?(text) }
  end
  
  def content=(stuff) # !> method redefined; discarding old content=
    @content = { :type => self.class.name.to_s }
    import(stuff)
    eval_specials
    eval_defaults
    parse_tags unless blank_attr?(:tags)
    generate_slug if get_attr?(:slug)
    @content
  end#of content=
  
  def valid? # TODO: this doesn't work if there are no required fields and the slug is not unique
    !self.class.required_fields_list.blank? && 
    self.class.required_fields_list.reject { |item| !get_attr(item).blank? }.blank? && 
    slug_is_unique
  end
  
  def initialize(text = nil)
    if text
      self.content = text
      # sanitize_content_fields
    end
  end
  
  def save
    if valid?
      truncate_slug if self.class.truncate_slugs
      fill_default_fields
      send_to_storage
    else
      false
    end
  end
  
  def import(stuff)
    import_text(stuff) # TODO: make it possible to import other types
  end

  # TODO: move this to a from_text method on String
  def import_text(text)
    pairs, remainder = pull_pairs(text)
    commit_pairs(pairs)
    eval_primary_field(remainder) unless self.class.primary_field.blank?
  end

  def pull_pairs(text)
    pairs = []
    remainder = ''
    last_pair_found = false
  
    text.each_line do |line|
    
      unless last_pair_found
        possible_pair = detect_pair(line)
        if possible_pair and possible_pair.captures.length == 2
          key = possible_pair.captures[0].downcase.to_sym
          value = possible_pair.captures[1]
          number_of_lines = value.count("\n") + 1
          pairs << { key => value.strip }
          next # don't put this in the remainder
        else
          last_pair_found = true
        end#of if
      end
    
      remainder << line # keep this around, it might be useful
    end#of each_line
  
    [pairs, remainder.strip]
  end#of parse_pairs

  def detect_pair(line)
    line.strip.match(/(^[A-Za-z0-9_]+):(.+)/)
  end

  def commit_pairs(pairs_array)
    pairs_array.each do |pairs_hash|
      pairs_hash.each do |key, value|
        set_attr(key, value)
      end
    end
  end

  def eval_primary_field(remainder)
    remainder.strip!
  
    unless remainder.blank?
      set_attr(self.class.primary_field, remainder)
      eval_heading_field # there can only be a heading if there is a primary
    end
  end

  def eval_heading_field
    unless self.class.heading_field.blank?
      # check for an <h1> at the beginning of the primary and if it's there pull it out for the heading
      possible_hone = get_attr(self.class.primary_field).match(/^<h1>(.+)<\/h1>/)

      if possible_hone and possible_hone.captures.length == 1
        set_attr(self.class.heading_field, possible_hone.captures.first)
      
        ### Remove heading from text
        new_text = get_attr(self.class.primary_field, false).
                   strip.
                   gsub(/^#{possible_hone.captures.first}\n=+\n*/, '').
                   gsub(/^# #{possible_hone.captures.first}\w*\n*/, '').
                   strip
        
        set_attr(self.class.primary_field, new_text)
      end#of if
    end#of unless
  end#of eval_heading_field

  def eval_defaults
    if valid?
      self.class.defaults_blocks.each do |key, block|
        if get_attr(key).blank?
          set_attr(key, self.instance_eval(&block))
        end
      end
    end
  end

  def eval_specials
    self.class.specials_blocks.each do |key, block|
      unless get_attr(key).blank?
        set_attr(key, block.call(get_attr(key)))
      end
    end
  end

  def parse_tags
    if get_attr(:tags).class == String
      tags_array = get_attr(:tags).split(',').collect { |t| t.strip }
      set_attr(:tags, tags_array)
    end
  end

  def sanitize_content_fields
    @content.reject! { |key, value| !self.class.allowed_fields_list.include?(key) }
  end

  def send_to_storage # send to the db or whatever
    false
  end

  def slug_is_unique # validate uniqueness
    true
  end

  def fill_default_fields
    set_default(:published_at, Time.now.utc)
    set_default(:status, default_status)
  end

  def generate_slug # OPTIMIZE: this slug generation is ugly
    result = ''
  
    unless self.class.always_use_uuid
      result = get_attr(self.class.heading_field).to_s.dup unless self.class.heading_field.blank?
  
      if result.blank?
        result = get_attr(self.class.primary_field, false).to_s.dup unless self.class.primary_field.blank?
      end
  
      if result.blank?
        self.class.required_fields_list.each do |required_field|
          unless get_attr(required_field).blank?
            result = get_attr(required_field).to_s.dup
            break
          end#of unless
        end#of each
      end#of if
  
      result.slugify!
    end#of unless
  
    if result.blank?
      result = uuid
    end
  
    set_attr(:slug, result)
  end

  def truncate_slug(letter_count = 50)
    unless get_attr(:slug).blank?
      new_slug = get_attr(:slug).gsub(/^(.{#{letter_count}})(.*)/) { $1.slugify }
      set_attr(:slug, new_slug)
    end
  end

  def default_status
    :published
  end

  def post_to_trackbacks
    false
  end

  def uuid
    UUID.timestamp_create.to_s
  end
  
end