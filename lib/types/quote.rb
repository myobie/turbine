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
    pairs, remainder = new.pull_pairs(text)
    
    markdown = Markdown.new(remainder.strip)
    remainder_html = markdown.to_html.strip
    
    q_count = pairs.reject { |pair| pair.keys.first != :quote }
    q_count.length == 1 || !(remainder_html =~ /^<blockquote(.+)<\/blockquote>$/m).nil?
  end
end