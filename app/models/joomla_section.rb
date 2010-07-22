class JoomlaSection < ActiveRecord::Base

  set_table_name 'jos_sections'

  def before_validation_on_create
    self.checked_out_time = 5.hours.ago unless checked_out_time
    self.scope = "content"
    self.published = 1
    self.alias = title.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias[/\w/]
  end

  has_many :categories, :class_name => "JoomlaCategory", :foreign_key => :section
  has_many :articles, :class_name => "JoomlaArticle", :foreign_key => :sectionid

  acts_as_list :column => :ordering

  validates_presence_of :title
  validates_uniqueness_of :title
  validates_format_of :alias, :with => /^[-\w]+/
  validates_uniqueness_of :alias

  def restore_integrity! order_on = :title
    correct_order = categories.all(:order => order_on)
    1.upto(correct_order.count) do |i|
      correct_order[i-1].restore_integrity! i
    end
    self.count = articles.count
    save!
  end

end
