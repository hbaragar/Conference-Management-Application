class JoomlaCategory < Joomla

  include MyHtml

  set_table_name 'jos_categories'

  belongs_to :joomla_section, :class_name => "JoomlaSection", :foreign_key => :section

  def before_validation_on_create
    self.checked_out_time = 5.hours.ago unless checked_out_time
    self.published = 1
  end

  has_many :articles, :class_name => "JoomlaArticle", :foreign_key => :catid

  default_scope :order => "ordering"

  acts_as_list :column => :ordering, :scope => %q{section = '#{section}'}

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :section
  validates_format_of :alias, :with => /^[-\w]+/
  validates_uniqueness_of :alias, :scope => :section

  def restore_integrity! position = nil
    purge_articles_for_deleted_colocated_conferences
    self.ordering = position if position
    self.count = articles.count
    save!
  end

  def purge_articles_for_deleted_colocated_conferences
    return unless self.alias == 'colocated-conferences'
    articles.each {|a| a.destroy unless a.conference}
  end

  def cfp
    articles.first.cfp
  end

  def populate_overview_article fulltext
    article = find_or_create_overview_article
    article.update_attributes!(:fulltext => div("overview", fulltext))
    article
  end

private

  def find_or_create_overview_article
    article = articles.find_by_title(title)||
      articles.create!(:title => title, :sectionid => section)
    attribs = article.attribs.clone
    attribs[/show_category=(\d*)/,1] = "0"
    attribs[/show_section=(\d*)/,1] = "0"
    article.update_attributes!(:attribs => attribs)
    article
  end

end
