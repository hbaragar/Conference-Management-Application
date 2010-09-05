class Session < ActiveRecord::Base

  include MyHtml

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

  validates_uniqueness_of :name, :scope => :portfolio_id

  def before_save
    self.name = html_encode_non_ascii_characters(name)
  end

  def after_save
    portfolio.changes_pending!
  end

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

  def time_slot include_day = "%a "
    (starts_at.strftime("#{include_day}%I:%M") + ends_at.strftime("-%I:%M %p").downcase).gsub(/(^|\s|-)0/, '\1')
  end

  def intro_html
    div("session",
      coordinates_to_html,
      if single_presentation?
	presentations.first.intro_html rescue ""
      elsif presentations.count > 0
	ol(presentations.*.intro_html)
      else
        "Content to be Determined"
      end
   )
  end

  def to_html
    div("session",
      coordinates_to_html,
      if presentations.count > 0
	presentations.*.to_html
      else
        "<h4>Content to be Determined</h4>"
      end
   )
  end

  def coordinates_to_html
    div("coordinates",
      "#{time_slot} - #{room_to_html}"
    )
  end

  def room_to_html
    room || 'Room TBD'
  end

  def at_a_glance_html include_portfolio = true
    title = presentations.*.at_a_glance_title.join("\n")
    [
      (portfolio.at_a_glance_html if portfolio && include_portfolio),
      (joomla_article ? internal_link(joomla_article.html_link, name, title) : name)
    ].compact.join " "
  end

  def populate_joomla_program category
    unless joomla_article
      self.joomla_article = category.articles.create!(:title => name, :sectionid => category.section)
      save
    end
    attribs = joomla_article.attribs.clone
    attribs[/show_section=(\d*)/,1] = "1"
    attribs[/show_category=(\d*)/,1] = all_presentations_in_one? ? "0" : "1"
    attribs[/show_intro=(\d*)/,1] = "0"
    joomla_article.update_attributes!(
      :title	=> name,
      :sectionid=> category.section,
      :attribs	=> attribs,
      :introtext=> intro_html,
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
