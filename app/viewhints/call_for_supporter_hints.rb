class CallForSupporterHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2

  parent :portfolio

  children :supporter_levels, :supporter_levels

  field_help :details => %q(Introductory paragraphs are automatically generated from the
      portfolio and conference descriptions,
      and it will be converted to HTML using
      <a href="http://daringfireball.net/projects/markdown/syntax" target="_blank">markdown</a>
      (similar to wiki markup)
    )
  
end
