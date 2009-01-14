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
    pairs = TextImporter.new(self.class).import(text)
    url_count = pairs.reject { |pair| pair.keys.first != :url }
    url_count.length == 1
  end
end