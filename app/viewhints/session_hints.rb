class SessionHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2

  parent :portfolio

  children :presentations, :involvements

  field_help :duration => "in minutes &mdash; use 210 for half day sessions and 540 for full day sesssions",
    :short_name => 'used on the schedule-at-a-glance'

end
