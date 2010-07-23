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

  belongs_to :joomla_general_section, :class_name => "JoomlaSection"	# For the Hosting conference

  belongs_to :joomla_article, :class_name => "JoomlaArticle"		# For Colocated conferences

  belongs_to :joomla_cfp_section, :class_name => "JoomlaSection"
  belongs_to :joomla_cfp_menu, :class_name => "JoomlaMenu"

  belongs_to :joomla_program_section, :class_name => "JoomlaSection"
  belongs_to :joomla_program_menu, :class_name => "JoomlaMenu"

  has_many :colocated_conferences, :class_name => "Conference", :foreign_key => :colocated_with_id
  has_many :portfolios, :dependent => :destroy
  has_many :cfps, :through => :portfolios
  has_many :call_for_supporters, :through => :portfolios
  has_many :sessions, :through => :portfolios
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

  def publish_to_joomla content
    script_path =  "#{File.dirname(__FILE__)}/../../script"
    unless ENV['PATH'][/^script_path/]
	ENV['PATH'] = script_path + ":" + ENV['PATH']
    end
    system("pull-from-joomla") && self.method("generate_#{content}").call && system("push-to-joomla") 
  end

  def generate_general_information
    generate_general_content
    set_up_general_menu
  end

  def generate_cfps
    generate_cfp_content
    generate_cfp_menu
  end

  def generate_program
    generate_program_content
    generate_program_menu
  end

  def general_category_for title
    host_conference = colocated_with || self
    host_conference.joomla_general_section.categories.find_by_title(title) ||
      host_conference.joomla_general_section.categories.create!(:title => title)
  rescue
    nil
  end


  # --- Permissions --- #

  never_show :joomla_general_section, :joomla_article
  never_show :joomla_cfp_menu, :joomla_cfp_section
  never_show :joomla_program_menu, :joomla_program_section

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

protected

  def set_up_joomla_general_section
    return if colocated_with
    return if joomla_general_section
    self.joomla_general_section = JoomlaSection.create!(:title => "General Information")
    save
  end

  def generate_general_content
    set_up_joomla_general_section
    generate_general_colocated_conferences_content
    generate_general_call_for_supporters_content
    joomla_general_section.restore_integrity!
  end

  def set_up_general_menu
    set_up_general_colocated_conferences_menu_item
    set_up_general_call_for_supporters_menu_item
  end

  def set_up_general_colocated_conferences_menu_item
    category = general_category_for('Colocated Conferences') or return
    menu = general_menu_item_for('Colocated Conferences') || JoomlaMenu.create(
      :name => 'Colocated Conferences',
      :sublevel => 0,
      :link => "index.php?option=com_content&view=category&layout=blog&id=#{category.id}"
    )
    menu.params[/show_title=\d/] = "show_title=0"
    menu.params[/show_category=\d/] = "show_category=0"
    menu.params += " "		# Force the save
    menu.save!
  end

  def generate_general_colocated_conferences_content
    colocated_conferences.each {|c| c.generate_general_colocated_conference_article}
    purge_unused_general_colocated_conference_articles
  end

  def generate_general_colocated_conference_article
    category = general_category_for('Colocated Conferences') or return
    unless joomla_article
      self.joomla_article = category.articles.create(
        :title => name,
        :sectionid => category.section
      )
      save!
    end
    fancy_title = name
    fancy_title = img(logo_url, "#{name} logo") if logo_url =~ /\w/
    fancy_title = external_link(url, fancy_title) if url =~ /\w/
    joomla_article.introtext = div("colocated_conference",
      h2(fancy_title),
      description,
      div("readon", external_link(url,"Read more: #{name}"))
    )
    joomla_article.save
  end

  def purge_unused_general_colocated_conference_articles
    general_category_for('Colocated Conferences').articles.each do |a|
      a.conference or a.destroy 
    end
  end

  def general_menu_item_for name, sublevel = 0
    JoomlaMenu.find_by_name_and_sublevel(name,sublevel)
  end

  def generate_general_call_for_supporters_content
    category = general_category_for 'Supporters'
    call_for_supporters.each{|c| c.generate_joomla_article(category)}
  end

  def set_up_general_call_for_supporters_menu_item
    menu_name = 'Supporters'
    category = general_category_for(menu_name) or return
    menu = general_menu_item_for(menu_name) || JoomlaMenu.create(
      :name => menu_name,
      :sublevel => 0,
      :link => "index.php?option=com_content&view=category&layout=blog&id=#{category.id}"
    )
    call_for_supporters.each do |c|
      item = general_menu_item_for(c.name, 1) || menu.items.create(
        :name => c.name,
        :sublevel => 1,
        :link => "index.php?option=com_content&view=article&id=#{c.joomla_article_id}"
      )
    end
  end

  def generate_cfp_content
    unless joomla_cfp_section
      self.joomla_cfp_section = JoomlaSection.create(:title => "Call for Papers", :alias => "cfp")
      save
    end
    cfps.each{|c| c.generate_joomla_article}
    joomla_cfp_section.restore_integrity! :checked_out_time
    joomla_cfp_section.categories.find_all_by_count(0){|c| c.destroy}
  end

  def generate_cfp_menu
    unless joomla_cfp_menu
      self.joomla_cfp_menu = JoomlaMenu.create(
        :name  => "Call for Papers",
        :alias => "cfp",
        :link  => "index.php?option=com_content&view=section&layout=blog&id=#{joomla_cfp_section.id}"
      )
      save
    end
    purge_unused_menu_items
    create_new_menu_items
    reorder_cfp_menu_items
  end

  def purge_unused_menu_items
    joomla_cfp_menu.items.each do |i|
      i.destroy unless joomla_cfp_section.categories.find_by_title(i.name)
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

  def generate_program_content
    unless joomla_program_section
      self.joomla_program_section = JoomlaSection.create(:title => "Program")
      self.joomla_program_menu = JoomlaMenu.create(:name  => "Program",
        :link  => "index.php?option=com_content&view=section&layout=blog&id=#{joomla_program_section.id}"
      )
      save
    end
    portfolios.each{|p| p.generate_program_content}
    joomla_program_section.restore_integrity!
    joomla_program_menu.restore_integrity!
  end

  def generate_program_menu
  end

end
