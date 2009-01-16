class Link < PostType
  fields :url, :title, :description
  required :url
  primary :description
  heading :title
  
  special :url do |link_content|
    'http://' + link_content.gsub(/^http:\/\//, '')
  end
  
  default :title do
    result = ''
    
    begin
      doc = Nokogiri::HTML(open(get_attr(:url)))
      doc.css('title').each { |t| result = t.content }
    rescue Exception => e
    end
    
    result
  end
  
  def self.detect?(text)
    has_required? text
  end
end