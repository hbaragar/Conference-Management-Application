class PresentationHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2

  parent :portfolio
  children :involvements

  field_help :reg_number => "the ID from the Registration System",
    :abstract => 'will be formatted using
      <a href="http://daringfireball.net/projects/markdown/" target="_blank">markdown</a>
    ',
    :objectives => 'will be formatted using
      <a href="http://daringfireball.net/projects/markdown/" target="_blank">markdown</a>
    ',
    :resume => 'will be formatted using
      <a href="http://daringfireball.net/projects/markdown/" target="_blank">markdown</a>
    ',
    :short_title => 'used on the schedule-at-a-glance
    '

end
