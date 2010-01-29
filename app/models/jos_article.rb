class JosArticle < ActiveRecord::Base

  set_table_name 'jos_content'

  def before_validation
    self.modified = Time.now
    self.checked_out_time = Time.now
    self.publish_up = Time.now
    self.publish_down = 100.years.from_now
    self.created = Time.now
    self.state = 1
    self.alias = title.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias[/\w/]
  end

  acts_as_list :column => :ordering

  validates_presence_of :title
  validates_uniqueness_of :title
  validates_format_of :alias, :with => /^[-\w]+/
  validates_uniqueness_of :alias

end
