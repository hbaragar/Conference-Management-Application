class Joomla < ActiveRecord::Base

  def before_validation
    self.alias = title.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias && self.alias[/\w/]
  end

  def populate_overview_article fulltext
    article = find_or_create_overview_article
    article.update_attributes!(:fulltext => div("overview", fulltext))
    article
  end

private

  def find_or_create_overview_article
    category = if self.class.name == 'JoomlaSection'
      categories.find_by_title("Overview") ||
        categories.create!(:title => "Overview")
    elsif self.class.name == 'JoomlaCategory'
      self
    end
    return unless category
    article = category.articles.find_by_title(title)||
      category.articles.create!(:title => title, :sectionid => category.section)
    attribs = article.attribs.clone
    attribs[/show_category=(\d*)/,1] = "0"
    attribs[/show_section=(\d*)/,1] = "0"
    article.update_attributes!(:attribs => attribs)
    article
  end

end
