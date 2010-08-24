class Day

  include MyHtml

  attr_reader :date, :sessions
  attr_accessor :joomla_category, :joomla_article, :joomla_menu
  
  def initialize attribs
    @date = attribs[:date]
    @sessions = attribs[:sessions]
  end

  def name
    "Due #{date.strftime('%B %d, %Y')}"
  end

  def populate_joomla_schedule section, extras
    # Kluge: category checked_out_time is not used during the generatation of content,
    #        so co-opt it for sorting purposes (see JoomlaSection::restore_integrity!)
    find_or_create_joomla_category_in section
    find_or_create_joomla_article_in joomla_category
    find_or_create_joomla_menu_in extras[:menu]
#    overview_text = [
#      h4(internal_link(joomla_category, name)),
#	ul(sessions.collect{|c| c.populate_joomla_call_for_papers joomla_category})
#    ]
    overview_text = ""
  end

  def find_or_create_joomla_category_in section
    self.joomla_category = section.categories.find_by_title('Days') ||
      section.categories.create!(:title => 'Days')
    joomla_category.update_attributes(:alias => nil)
    joomla_category
  end

  def find_or_create_joomla_article_in category
    self.joomla_article = category.articles.find_by_title(name) ||
      category.articles.create!(:title => name, :checked_out_time => date)
    joomla_article.update_attributes(:alias => nil)
    joomla_category
  end

  def find_or_create_joomla_menu_in menu
    joomla_menu = menu.items.find_by_name(name) || menu.items.create(:name => name)
    joomla_menu.update_attributes(
      :checked_out_time	=> date,
      :parent		=> menu.id,
      :sublevel		=> 1,
      :link		=> JoomlaMenu::link_for(joomla_article),
      :alias		=> nil
    )
    joomla_menu
  end

end
