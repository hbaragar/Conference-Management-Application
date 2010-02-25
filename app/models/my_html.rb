module MyHtml

protected

  def div(css_class, *text)
    return "" unless text
    %Q(<div #{tag_attributes({:class => css_class})}>#{text.join("")}\n</div>\n)
  end

  def h2(*text)
    return "" unless text
    %Q(<h2>#{text.join("")}</h2>\n)
  end

  def h3(*text)
    return "" unless text
    %Q(<h3>#{text.join("")}</h3>\n)
  end

  def ul(*text_list)
    text = text_list.join("")
    "\n<ul>\n#{text}</ul>\n" unless text.empty?
  end

  def ol(*text_list)
    text = text_list.join("")
    "\n<ol>\n#{text}</ol>\n" unless text.empty?
  end

  def li(*text)
    "<li>#{text.join('')}</li>\n"
  end

  def table(attributes,*text)
    "\n<table #{tag_attributes(attributes)}>\n#{text.join('')}\n</table>\n" unless text.empty?
  end

  def tr(attributes,*text)
    %Q(\n<tr #{tag_attributes(attributes)}>\n#{text.join('')}</tr>\n)
  end

  def th(attributes, *text)
    "<th #{tag_attributes(attributes)}>#{text.join('')}</th>\n"
  end

  def td(attributes, *text)
    %Q(<td #{tag_attributes(attributes)}>#{text.join('')}</td>\n)
  end

  def email_link addressees=email_address, address=email_address
    %Q(<a href="mailto:#{address}">#{addressees}</a>)
  end

  def external_link url, text
    %Q(<a href="#{url}" target="_blank">#{text}</a>)
  end

  def tag_attributes attributes
    attributes.collect{|k,v| %Q(#{k}="#{v}")}.join(" ")
  end

end
