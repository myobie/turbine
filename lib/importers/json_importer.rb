class JsonImporter
  
  attr_accessor :result, :type
  
  def initialize(type)
    @type = type
    @result = {}
  end
  
  def import(json_text)
    @result = JSON.parse(json_text)
  end
  
end