class JoomlaSection < ActiveRecord::Base

  include MyHtml

  set_table_name 'jos_sections'

  def before_validation
    self.alias = title.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias && self.alias[/\w/]
  end

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

  def populate_overview_article list
    article = find_or_create_overview_article
    article.update_attributes!(:fulltext => div("overview", ul(list)))
    article
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

private

  def find_or_create_overview_article
    category = categories.find_by_title("Overview") ||
      categories.create!(:title => "Overview")
    category.articles.find_by_title(title)||
      category.articles.create!(:title => title, :sectionid => id)
  end

end
