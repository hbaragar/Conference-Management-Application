class JoomlaSection < Joomla

  include MyHtml

  set_table_name 'jos_sections'

  def before_validation_on_create
    self.checked_out_time = 5.hours.ago unless checked_out_time
    self.scope = "content"
    self.published = 1
  end

  has_many :categories, :class_name => "JoomlaCategory", :foreign_key => :section
  has_many :articles, :class_name => "JoomlaArticle", :foreign_key => :sectionid

  acts_as_list :column => :ordering

  validates_presence_of :title
  validates_uniqueness_of :title
  validates_format_of :alias, :with => /^[-\w]+/
  validates_uniqueness_of :alias

  def after_destroy
    DeferredDeletion.create(:joomla_section_id => id)
  end

  def restore_integrity! order_on = :title
    purge_categories_for_deleted_cfp_due_dates
    categories.all(:order => (order_on||:title)).each_with_index do |category, index|
      category.update_attributes(:ordering => index + 1)
    end
    self.count = articles.count
    save!
  end

  def purge_categories_for_deleted_cfp_due_dates
    return unless self.alias == 'cfp'
    categories.each {|c| c.destroy unless c.articles.count > 0}
  end

  def link
    self.alias
  end

end
