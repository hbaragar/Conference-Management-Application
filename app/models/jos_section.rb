class JosSection < ActiveRecord::Base

  def before_validation
    self.checked_out_time = Time.now
    self.scope = "content"
    self.alias = title.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias[/\w/]
  end

  has_many :categories, :class_name => "JosCategory", :foreign_key => :section
  has_many :articles, :class_name => "JosArticle", :foreign_key => :sectionid

  acts_as_list :column => :ordering

  validates_presence_of :title
  validates_uniqueness_of :title
  validates_format_of :alias, :with => /^[-\w]+/
  validates_uniqueness_of :alias

end
