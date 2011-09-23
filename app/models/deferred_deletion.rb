class DeferredDeletion < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :joomla_article,	:index => false
  belongs_to :joomla_category,	:index => false
  belongs_to :joomla_menu,	:index => false
  belongs_to :joomla_section,	:index => false

  fields do
    timestamps
  end

  def before_destroy
    joomla_article.delete	if joomla_article
    joomla_category.delete	if joomla_category
    joomla_menu.delete		if joomla_menu
    joomla_section.delete	if joomla_section
    true
  end

end
