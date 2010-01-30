class Conference < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :colocated_with, :class_name => "Conference"

  fields do
    name        :string, :required
    description :markdown
  end

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

  def generate_cfps
    # Order matters here:
    generate_joomla_cfp_articles
    generate_joomla_cfp_section
    generate_joomla_cfp_categories
    generate_joomla_cfp_menu
  end

  def generate_joomla_cfp_articles
    cfps.each{|c| c.publish}
  end

  def generate_joomla_cfp_section
    unless joomla_cfp_section
      self.joomla_cfp_section = JoomlaSection.create(:title => "Call for Papers", :alias => "cfp")
      save
    end
    cfps.each{|c| joomla_cfp_section.articles << c.joomla_article}
    joomla_cfp_section.count = cfps.count
    joomla_cfp_section.save
  end

  def generate_joomla_cfp_categories
    categories = {}
    cfps.each do |c|
      title = c.joomla_category_title
      category =
	categories[c.due_on] ||= joomla_cfp_section.categories.find_by_title(title) ||
      				 joomla_cfp_section.categories.create(:title => title) 
      category.articles << c.joomla_article
    end
    categories.sort.reverse.each do |k, v|
      v.count = v.articles.count
      v.move_to_top
      v.save
    end
  end

  def generate_joomla_cfp_menu
    unless joomla_cfp_menu
      self.joomla_cfp_menu = JoomlaMenu.create(:name => "Call for Papers", :alias => "cfp")
      save
    end
    joomla_cfp_section.categories.each do |c|
      if item = joomla_cfp_menu.items.find_by_name(c.title)
	item.ordering = c.ordering
	item.save
      else
	joomla_cfp_menu.items << JoomlaMenu.create(
	  :name => c.title,
	  :alias => c.alias,
	  :ordering => c.ordering
	)
      end
    end
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
    acting_user.signed_up?
  end

end
