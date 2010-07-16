class PortfolioHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2

  children :presentations, :members

  field_help :public_email_address => "to be published on the website", 
    :description => %q(will be used as an introduction to the CFP,
      and it will be converted to HTML using
      <a href="http://daringfireball.net/projects/markdown/" target="_blank">markdown</a>
      (similar to wiki markup)
    )

end
