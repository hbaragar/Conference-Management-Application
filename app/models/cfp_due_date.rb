class CfpDueDate

  attr_reader :due_on, :cfps
  attr_accessor :joomla_category, :joomla_menu
  
  def initialize attribs
    @due_on = attribs[:due_on]
    @cfps = attribs[:cfps]
  end

  def name
    "Due #{due_on.strftime('%B %d, %Y')}"
  end

  def populate_joomla_cfp section, menu
    # Kluge: category checked_out_time is not used during the generatation of content,
    #        so co-opt it for sorting purposes (see JoomlaSection::restore_integrity!)
    self.joomla_category = find_or_create_category_in section
    self.joomla_menu = find_or_create_item_in menu
    cfps.each{|c| c.populate_joomla_call_for_papers joomla_category}
  end

  def find_or_create_category_in section
    fields = { :title => name, :checked_out_time => due_on.to_datetime }
    section.categories.find(:first, :conditions => fields) || section.categories.create!(fields)
  end

  def find_or_create_item_in menu
    fields = {
      :name		=> name, 
      :checked_out_time	=> due_on.to_datetime,
      :sublevel		=> 1,
      :link		=> JoomlaMenu::link_for(joomla_category)
    }
    menu.items.find(:first, :conditions => fields) || menu.items.create(fields)
  end

end
