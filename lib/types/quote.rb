class Quote < PostType
  fields :quote, :source
  required :quote
  primary :quote
  
  special :quote do |quote_content|
    unless (quote_content =~ /^<blockquote/).nil?
      doc = Nokogiri::HTML(quote_content)
      doc.css('blockquote').each { |q| quote_content = q.content }
    end
    quote_content.strip
  end
  
  def self.detect?(text)
    pairs = TextImporter.new(self.class).import(text)
    
    the_quote = pairs.select { |pair| pair.keys.first == :quote }
    
    markdown = Markdown.new(the_quote[:quote])
    quote_html = markdown.to_html.strip
    
    q_count = pairs.reject { |pair| pair.keys.first != :quote }
    q_count.length == 1 || !(quote_html =~ /^<blockquote(.+)<\/blockquote>$/m).nil?
  end
end