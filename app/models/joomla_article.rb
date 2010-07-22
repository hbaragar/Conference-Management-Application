class JoomlaArticle < ActiveRecord::Base

  set_table_name 'jos_content'

  belongs_to :category, :class_name => "JoomlaCategory", :foreign_key => :catid
  belongs_to :section, :class_name => "JoomlaSection", :foreign_key => :sectionid

  has_one :conference

  def before_validation_on_create
    self.modified = 5.hours.ago
    self.checked_out_time = 5.hours.ago unless checked_out_time
    self.publish_up = 5.hours.ago
    self.publish_down = 20.years.from_now - 5.hours
    self.created = 5.hours.ago
    self.state = 1
    self.alias = title.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias[/\w/]
  end

  acts_as_list :column => :ordering, :scope => 'catid = #{catid}'

  has_one :cfp, :foreign_key => :joomla_article_id
  has_one :call_for_supporter, :foreign_key => :joomla_article_id

  validates_presence_of :title
  validates_uniqueness_of :title
  validates_format_of :alias, :with => /^[-\w]+/
  validates_uniqueness_of :alias

end
