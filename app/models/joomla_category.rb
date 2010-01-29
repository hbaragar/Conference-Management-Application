class JoomlaCategory < ActiveRecord::Base

  set_table_name 'jos_categories'

  def before_validation
    self.checked_out_time = Time.now
    self.alias = title.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias[/\w/]
  end

  has_many :articles, :class_name => "JoomlaArticle", :foreign_key => :catid

  default_scope :order => "ordering"

  acts_as_list :column => :ordering, :scope => %q{section = '#{section}'}

  validates_presence_of :title
  validates_uniqueness_of :title
  validates_format_of :alias, :with => /^[-\w]+/
  validates_uniqueness_of :alias

end