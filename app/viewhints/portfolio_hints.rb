class PortfolioHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2

  presentation_fields = (
    Presentation.column_names -
    %w(id portfolio_id created_at updated_at position)
  ).join(", ")

  children :sessions, :members

  field_help :public_email_address => "to be published on the website", 
    :description => %q(will be used as an introduction to the CFP,
      and it will be converted to HTML using
      <a href="http://daringfireball.net/projects/markdown/" target="_blank">markdown</a>
      (similar to wiki markup)
    ),
    :typical_session_duration => "in minutes &mdash; use 210 for half day sessions and 510 for full day sesssions",
    :presentation_fields => "allowed values: #{presentation_fields}"

end
