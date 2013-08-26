class FacilityArea < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :conference

  fields do
    name :string
    timestamps
  end

  belongs_to :joomla_article

  has_many :rooms, :dependent => :destroy

  default_scope :order => :name

  validates_uniqueness_of :name, :scope => :conference_id

  def before_save
    self.name = html_encode_non_ascii_characters(name)
  end

  def after_destroy
    joomla_article.destroy if joomla_article
  end

  def populate_joomla_program category
    if joomla_article
      joomla_article.update_attributes!(:title => name)
    else
      self.joomla_article = category.articles.create!(:title => name, :sectionid => category.section)
      save
    end
  end


  # --- Permissions --- #

  never_show :joomla_article

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator? || chair?(acting_user)
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.administrator? || field != :joomla_article
  end

end
