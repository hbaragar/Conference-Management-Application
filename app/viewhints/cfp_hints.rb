class CfpHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2
 
  parent :portfolio

  field_help :due_on => "Other important dates can be added after the CFP has been created",
    :details => "Introductory paragraphs are automatically generated from the portfolio and conference descriptions"
end
