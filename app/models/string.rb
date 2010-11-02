class String

  def to_html
    CGI::escapeHTML(to_s).gsub(/'/, "&#39;")
  end

end
