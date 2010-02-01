class JoomlaMenu < ActiveRecord::Base

  set_table_name 'jos_menu'
  @inheritance_column = 'single_table_inheritance_not_being_used'

  PARAMS = %q(show_description=0
show_description_image=0
num_leading_articles=0
num_intro_articles=100
num_columns=1
num_links=0
orderby_pri=alpha
orderby_sec=alpha
multi_column_order=0
show_pagination=2
show_pagination_results=1
show_feed_link=1
show_noauth=
show_title=1
link_titles=1
show_intro=1
show_section=0
link_section=1
show_category=1
link_category=1
show_author=0
show_create_date=0
show_modify_date=0
show_item_navigation=0
show_readmore=1
show_vote=0
show_icons=0
show_pdf_icon=0
show_print_icon=0
show_email_icon=0
show_hits=
feed_summary=
page_title=
show_page_title=1
pageclass_sfx=
menu_image=-1
secure=0
    )

  def before_validation
    self.type = "component"
    self.componentid = JoomlaComponent.find_by_name('Articles').id
    self.menutype = "mainmenu"
    self.checked_out_time = 5.hours.ago
    self.published = 1
    self.alias = name.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias[/\w/] if name
    self.params = PARAMS 
  end

  def before_save
    self.params = PARAMS 
    if sublevel == 0
      self.params = params.sub(/orderby_pri=alpha/,"orderby_pri=order")
    else
      self.params = params.sub(/show_section=0/,"show_section=1")
    end
  end

  has_many :items, :class_name => 'JoomlaMenu', :foreign_key => :parent

  acts_as_list :column => :ordering

  validates_presence_of :name
  validates_presence_of :link
  validates_uniqueness_of :name, :scope => :parent
  validates_format_of :alias, :with => /^[-\w]+/
  validates_uniqueness_of :alias, :scope => :parent

end
