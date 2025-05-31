class Parser
  def parse(raw_doc, fields)
    doc = Nokogiri::HTML(raw_doc)
    fields.reduce({}) do |memo, (name, selector)|
      if name == "meta"
        memo[name] = parse_meta(doc, selector)
      else
        node = doc.at_css selector
        memo[name] = node&.text
      end
      memo
    end
  end

  private

  def parse_meta(doc, meta_fields)
    meta_fields.reduce({}) do |memo, field|
      memo[field.to_s] = doc.at_xpath("//meta[@name=\"#{field}\"]")&.attr("content")
      memo
    end
  end
end
