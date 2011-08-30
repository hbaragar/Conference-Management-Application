module MyHtml

  require 'string.rb'

protected

  CHARACTER_ENCODING = {
    /---/	=> "&mdash;",
    /--/	=> "&ndash;",
    /Ã©/	=> "&eacute;",
    /Ã/		=> "&agrave;",
    /ä/		=> "&auml;",
    /Ã¤/	=> "&auml;",
    /Ã¶/	=> "&ouml;",
    /ö/		=> "&ouml;",
    /Ö/		=> "&Ouml;",
  }.sort do |a,b|
      a[0].to_s.length <=> b[0].to_s.length
    end.reverse.freeze

  def html_encode_non_ascii_characters text
    return text
    text ||= ""
    CHARACTER_ENCODING.each do |k, v|
      text.gsub! k, v
    end
    text
  end

  def div(css_class, *text)
    return "" unless text
    %Q(<div #{tag_attributes({:class => css_class})}>#{text.join("")}</div>\n)
  end

  def hn(n,*text)
    return "" unless text
    %Q(<h#{n}>#{text.join("")}</h#{n}>\n)
  end

  def h2(*text)
    hn(2,text)
  end

  def h3(*text)
    hn(3,text)
  end

  def h4(*text)
    hn(4,text)
  end

  def h5(*text)
    hn(5,text)
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

  def internal_link link, text, title = ""
    link = link.link rescue link
    link = JoomlaMenu::link_for(link) if link.class.name =~ /Joomla/
    %Q(<a href="#{link}" #{tag_attributes(:title => title)}>#{text}</a>)
  end

  def external_link url, text
    %Q(<a href="#{url}" target="_blank">#{text}</a>)
  end

  def email_link addressees=email_address, address=email_address
    %Q(<a href="mailto:#{address}">#{(addressees||"").gsub(/['"]/,"\\\\\1")}</a>)
  end

  def img src, alt=""
    %Q(<img src="#{src}" alt="#{alt}"/>)
  end

  def span(css_class, *text)
    return "" unless text
    display_text = text.join("")
    return unless display_text =~ /\S/
    %Q(<span class="#{css_class}">#{display_text}</span>)
  end

  def tag_attributes attributes
    attributes.collect{|k,v| %Q(#{k}="#{v}")}.join(" ")
  end

end
