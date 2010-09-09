class URL < String

  COLUMN_TYPE = :string

  HoboFields.register_type(:url, self)

  def validate
    I18n.t("activerecord.errors.messages.invalid") unless valid? || blank?
  end

  def valid?
    self =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
  end

  def to_html(xmldoctype = true)
    "<a href='#{self}'>#{self}</a>"
  end

end
