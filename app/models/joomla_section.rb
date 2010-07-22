class JoomlaSection < ActiveRecord::Base

  set_table_name 'jos_sections'

  def before_validation
    self.checked_out_time = 5.hours.ago
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

  def update_count!
    self.count = articles.count
    save!
  end

  def clean_up_cfp_categories
    in_use = {}
    categories.each do |c|
      c.update_count!
      if c.count == 0
	c.destroy
      else
	in_use[c.cfp.due_on] = c
      end
    end
    sorted_categories = in_use.sort.collect{|a| a[1]}
    1.upto(sorted_categories.count) do |i|
      c = sorted_categories.shift
      c.ordering = i
      c.save
    end
  end

  def clean_up_program_categories
    categories.each do |c|
      c.update_count!
    end
    sorted_categories = categories.all(:order => :title)
    1.upto(sorted_categories.count) do |i|
      c = sorted_categories[i-1]
      c.ordering = i
      c.save
    end
  end

end
