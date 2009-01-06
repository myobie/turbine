class String
  def slugify
    self.dup.slugify!
  end
  
  def slugify!
    self.gsub!(/[^\x00-\x7F]+/, '') # Remove non-ASCII (e.g. diacritics).
    self.gsub!(/[^a-z0-9\-_\+]+/i, '-') # Turn non-slug chars into the separator.
    self.gsub!(/-{2,}/, '-') # No more than one of the separator in a row.
    self.gsub!(/^-|-$/, '') # Remove leading/trailing separator.
    self.downcase!
    self
  end
  
  def make_attr
    self.downcase.to_sym
  end
end

class Symbol
  def html
    (self.to_s + '_html').to_sym
  end
  
  def make_attr
    self.to_s.downcase.to_sym
  end
end

class Array # !> method redefined; discarding old to_datetime
  def make_attrs
    self.collect! { |a| a.to_s.downcase.to_sym }
  end
end

### class instance vars that inherit down to children
module ClassLevelInheritableAttributes
  
  PRIMITIVES = [NilClass, TrueClass, FalseClass, Fixnum, Float]
  
  def cattr_inheritable(*args)
    @cattr_inheritable_attrs ||= [:cattr_inheritable_attrs]
    @cattr_inheritable_attrs += args
    args.each do |arg|
      class_eval %(
        class << self; attr_accessor :#{arg}; end
      )
    end
    @cattr_inheritable_attrs
  end

  def inherited(subclass)
    @all_children ||= []
    @cattr_inheritable_attrs.each do |inheritable_attribute|
      instance_var = "@#{inheritable_attribute}" 
      current_value = instance_variable_get(instance_var)
      current_value = current_value.dup unless PRIMITIVES.include?(current_value.class)
      subclass.instance_variable_set(instance_var, current_value)
    end
    @all_children << subclass
  end

end