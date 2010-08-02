class Session < ActiveRecord::Base

  DEFAULT_NAME = "To Be Scheduled".freeze

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :portfolio

  fields do
    name      :string, :required, :default => DEFAULT_NAME
    starts_at :datetime, :required, :default => '2010-10-22 08:00'
    duration  :integer
    timestamps
  end

  belongs_to :room
  belongs_to :joomla_article

  has_many :presentations
  has_many :involvements, :through => :presentations

  default_scope :order => "starts_at, name"

  def before_create
    self.duration ||= portfolio.typical_session_duration
  end

  def ends_at
    starts_at + duration.minutes
  end

  def conference
    portfolio.conference
  end

  def multiple_presentations?
    portfolio.session_type == "multiple_presentations"
  end

  def time_slot
    (starts_at.strftime("%a %H:%M") + ends_at.strftime("-%H:%M %p").downcase).gsub(/(\s|-)0/, '\1')
  end

  def to_html
    div("session",
      coordinates_to_html,
      presentations.collect {|p| p.to_html}
   )
  end

  def coordinates_to_html
    div("coordinates",
      "Co-ordinates TBA"
    )
  end

  def populate_joomla_program category
    unless joomla_article
      self.joomla_article = category.articles.create!(:title => name, :sectionid => category.section)
      save
    end
    attribs = joomla_article.attribs.clone
    attribs[/show_category=(\d*)/,1] = "0"
    attribs[/show_section=(\d*)/,1] = "0"
    joomla_article.update_attributes!(
      :title	=> name,
      :sectionid=> category.section,
      :attribs	=> attribs,
      :fulltext	=> to_html
    )
    joomla_article.reload
  end


  # --- Permissions --- #

  never_show :joomla_article

  def create_permitted?
    return true if acting_user.administrator?
    return false unless portfolio
    portfolio.chair?(acting_user) || conference.chair?(acting_user)
  end

  def update_permitted?
    return false if portfolio_id_changed?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def destroy_permitted?
    return false if presentations.count > 0
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

  def initialize *args
    super *args
    self.duration ||= portfolio.typical_session_duration
  end

end
