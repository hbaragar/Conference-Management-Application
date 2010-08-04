class Conference < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :colocated_with, :class_name => "Conference"

  fields do
    name        :string, :required
    url         :string
    logo_url    :string
    description :markdown
  end

  belongs_to :joomla_article, :class_name => "JoomlaArticle"		# For Colocated conferences

  has_many :colocated_conferences, :class_name => "Conference", :foreign_key => :colocated_with_id
  has_many :portfolios, :dependent => :destroy
  has_many :cfps, :through => :portfolios
  has_many :call_for_supporters, :through => :portfolios
  has_many :sessions, :through => :portfolios
  has_many :members, :through => :portfolios
  has_many :facility_areas, :dependent => :destroy

  def cfp_due_dates
    # For populating Call for Papers menu area
    cfps.collect{|c| c.due_on}.uniq.collect do |due_on|
      CfpDueDate.new(:due_on => due_on, :cfps => cfps.find_all_by_due_on(due_on))
    end
  end

  def selves
    # Kluge for populating the Home menu area
    [self]
  end

  def supporter_portfolios
    # Kluge for populating the Supporters menu area
    call_for_supporters.collect{|c| c.portfolio}.uniq
  end

  named_scope :host_conferences, :conditions => {:colocated_with_id => nil}

  def after_create 
    portfolios << Portfolio.new(:name => "General")
  end

  def publish_to_joomla menu_name
    script_path =  "#{File.dirname(__FILE__)}/../../script"
    unless ENV['PATH'][/^script_path/]
	ENV['PATH'] = script_path + ":" + ENV['PATH']
    end
    system("pull-from-joomla") && populate_joomla_menu_area_for(menu_name) && system("push-to-joomla") 
  end

  MAIN_MENU = [
    { :name => "Home",			:class => JoomlaSection,  :collection => "selves",	:alias => 'general-information' },
    { :name => "Program",		:class => JoomlaSection,  :collection => "portfolios" },
    { :name => "Call for Papers",	:class => JoomlaSection,  :collection => "cfp_due_dates", :alias => 'cfp', :order_on => :checked_out_time},
    { :name => "Colocated Conferences",	:class => JoomlaCategory, :collection => "colocated_conferences" },
    { :name => "Supporters",		:class => JoomlaCategory, :collection => "supporter_portfolios" },
  ]

  def populate_joomla_menu_area_for menu_name
    MAIN_MENU.each_with_index do |config, index|
      if [config[:name], "All Areas"].include? menu_name
	populate_joomla_menu_area_configured_by(config, index)
      end
    end
  end

  def populate_joomla_general_information section, index
    # Populated through Joomla itself
  end

  def populate_joomla_colocated_conferences category, index
    # called for each colocated conference (not for the host conference)
    unless joomla_article
      self.joomla_article = joomla_general_section.articles.create(:title => name, :catid => category.id)
      save!
    end
    fancy_title = name
    fancy_title = img(logo_url, "#{name} logo") if logo_url =~ /\w/
    fancy_title = external_link(url, fancy_title) if url =~ /\w/
    joomla_article.update_attributes(
      :introtext => div("colocated_conference",
	h2(fancy_title),
	description.to_html,
	div("readon", external_link(url,"Read more: #{name}"))
      )
    )
    overview_text = li(name)
  end

  def joomla_general_section
    JoomlaSection.find_by_alias "general-information"
  end

  def chair? user
    (members & user.members).select do |m|
      m.portfolio.name == "General" && m.chair
    end.count > 0
  end


  # --- Permissions --- #

  never_show :joomla_article

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    return true if acting_user.administrator? 
    return false if any_changed?(:colocated_with_id)
    chair?(acting_user) || (colocated_with && colocated_with.chair?(acting_user))
  end

  def destroy_permitted?
    portfolios.empty? && acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

private

  def populate_joomla_menu_area_configured_by config, index
    area = joomla_area_for config
    menu = joomla_menu_for area, index
    populate_joomla_menu_area_with config[:collection], area, menu
    area.restore_integrity! config[:order_on]
    menu.restore_integrity! config[:order_on]
  end

  def joomla_area_for config
    area_class = config[:class]
    area_fields = {:title => config[:name]}
    area_fields[:section] = joomla_general_section.id if area_class == JoomlaCategory
    area = area_class.find(:first, :conditions => area_fields) || area_class.create!(area_fields)
    area.update_attributes!(:alias => config[:alias])
    area
  end

  def joomla_menu_for area, index
    menu = JoomlaMenu.find_by_name(area.title) || JoomlaMenu.create!(
    	:name => area.title,
	:link => JoomlaMenu::link_for(area)
    )
    params = menu.params.clone
    params[/show_section=(\d*)/,1] = "1"
    menu.update_attributes!(
      :alias => area.alias,
      :ordering => index+1,
      :params => params
    )
    menu
  end

  def populate_joomla_menu_area_with collection_name, area, menu
    populator = "populate_joomla_" + area.alias.gsub(/\W/,"_")
    overview_list = method(collection_name).call.collect do |item|
      item.method(populator).call(area, menu)
    end
    if area.class == JoomlaSection
      overview_article = area.populate_overview_article(overview_list)
      menu.update_attributes!(:link => JoomlaMenu::link_for(overview_article))
    else
      menu.update_attributes!(:link => JoomlaMenu::link_for(area))
    end
  end

end
