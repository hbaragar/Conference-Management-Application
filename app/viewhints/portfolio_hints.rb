class PortfolioHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2

  children :members

  field_help :email_address => "to be published on the website", 
    :description => "will be used as an introduction to the CFP"


end
