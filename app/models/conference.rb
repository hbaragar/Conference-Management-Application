class Conference < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :colocated_with, :class_name => "Conference"

  fields do
    name        :string, :required
    description :markdown
  end

  belongs_to :joomla_general_section, :class_name => "JoomlaSection"	# For the Hosting conference

  belongs_to :joomla_article, :class_name => "JoomlaArticle"		# For Colocated conferences

  belongs_to :joomla_cfp_section, :class_name => "JoomlaSection"
  belongs_to :joomla_cfp_menu, :class_name => "JoomlaMenu"

  has_many :colocated_conferences, :class_name => "Conference", :foreign_key => :colocated_with_id
  has_many :portfolios, :dependent => :destroy
  has_many :cfps, :through => :portfolios
  has_many :members, :through => :portfolios

  named_scope :host_conferences, :conditions => {:colocated_with_id => nil}

  def after_create 
    portfolios << Portfolio.new(:name => "General")
  end

  def chair? user
    (members & user.members).select do |m|
      m.portfolio.name == "General" && m.chair
    end.count > 0
  end

  def generate_general_information
    set_up_joomla_general_section
    generate_general_colocated_conferences_content
  end

  def generate_cfps
    generate_cfp_content
    generate_cfp_menu
  end

  # --- Permissions --- #

  never_show :joomla_cfp_menu
  never_show :joomla_cfp_section

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    (chair?(acting_user) && none_changed?(:colocated_with_id)) || acting_user.administrator? 
  end

  def destroy_permitted?
    portfolios.empty? && acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

protected

  def set_up_joomla_general_section
    return if colocated_with
    return if joomla_general_section
    self.joomla_general_section = JoomlaSection.create!(:title => "General Information")
    save
  end

  def generate_general_colocated_conferences_content
    colocated_conferences.each {|c| c.generate_general_colocated_conference_article}
    purge_unused_general_colocated_conference_articles
  end

  def generate_general_colocated_conference_article
    category = general_category_for('Colocated Conferences') or return
    unless joomla_article
      self.joomla_article = category.articles.create(
	:title	=> category.title,
	:sectionid => category.section
      )
      save!
    end
    joomla_article.introtext = [name, description].join("\n")
    joomla_article.save
  end

  def purge_unused_general_colocated_conference_articles
    general_category_for('Colocated Conferences').articles.each do |a|
      a.conference or a.destroy 
    end
  end

  def general_category_for title
    host_conference = colocated_with || self
    host_conference.joomla_general_section.categories.find_by_title(title) ||
      host_conference.joomla_general_section.categories.create!(:title => title)
  rescue
    nil
  end

  def generate_cfp_content
    unless joomla_cfp_section
      self.joomla_cfp_section = JoomlaSection.create(:title => "Call for Papers", :alias => "cfp")
      save
    end
    cfps.each{|c| c.generate_joomla_article}
    joomla_cfp_section.update_count!
    joomla_cfp_section.clean_up_cfp_categories
  end

  def generate_cfp_menu
    unless joomla_cfp_menu
      self.joomla_cfp_menu = JoomlaMenu.create(
	:name	=> "Call for Papers",
	:alias	=> "cfp",
	:link	=> "index.php?option=com_content&view=section&layout=blog&id=#{joomla_cfp_section.id}"
      )
    end
    save	# Always save in order to get the parametes updated
    purge_unused_menu_items
    create_new_menu_items
    reorder_cfp_menu_items
  end

  def purge_unused_menu_items
    joomla_cfp_menu.items.each do |i|
      next if joomla_cfp_section.categories.find_by_title(i.name)
      i.destroy
    end
  end

  def create_new_menu_items
    joomla_cfp_section.categories.each do |c|
      next if joomla_cfp_menu.items.find_by_name(c.title)
      joomla_cfp_menu.items.create(
	:name	=> c.title,
	:alias	=> c.alias,
	:link	=> "index.php?option=com_content&view=category&layout=blog&id=#{c.id}",
	:sublevel => 1
      )
    end
  end

  def reorder_cfp_menu_items
    joomla_cfp_section.categories.each do |c|
      item = joomla_cfp_menu.items.find_by_name(c.title)
      item.ordering = c.ordering
      item.save
    end
  end

end
