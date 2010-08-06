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

  default_scope :order => "starts_at, duration, name"

  def overlaps? rhs
    earlier, later = [self, rhs].sort
    earlier.starts_at + duration.minutes > later.starts_at
  end

  def <=> rhs
    cmp = starts_at <=> rhs.starts_at
    return cmp unless cmp == 0
    cmp = duration <=> rhs.duration
    return cmp unless cmp == 0
    cmp = name <=> rhs.name
  end

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
    portfolio.multiple_presentations_per_session?
  end

  def single_presentation?
    portfolio.single_presentation_per_session?
  end

  def all_presentations_in_one?
    portfolio.all_presentations_in_one_session?
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
      "#{time_slot} &mdash #{room || 'Room TBD'}"
    )
  end

  def populate_joomla_program category
    unless joomla_article
      self.joomla_article = category.articles.create!(:title => name, :sectionid => category.section)
      save
    end
    attribs = joomla_article.attribs.clone
    attribs[/show_section=(\d*)/,1] = "1"
    attribs[/show_category=(\d*)/,1] = all_presentations_in_one? ? "0" : "1"
    joomla_article.update_attributes!(
      :title	=> name,
      :sectionid=> category.section,
      :attribs	=> attribs,
      :fulltext	=> to_html
    )
    overview_text = li(internal_link(joomla_article, name)) unless all_presentations_in_one?
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
    self.duration ||= portfolio && portfolio.typical_session_duration
  end

end
