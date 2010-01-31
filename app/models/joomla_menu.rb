class JoomlaMenu < ActiveRecord::Base

  set_table_name 'jos_menu'
  @inheritance_column = 'single_table_inheritance_not_being_used'

  def before_validation
    self.checked_out_time = Time.now
    self.alias = name.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias[/\w/] if name
  end

  has_many :items, :class_name => 'JoomlaMenu', :foreign_key => :parent

  acts_as_list :column => :ordering

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :parent
  validates_format_of :alias, :with => /^[-\w]+/
  validates_uniqueness_of :alias, :scope => :parent

end
