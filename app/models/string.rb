class String

  def to_html
    CGI::escapeHTML to_s
  end

end
