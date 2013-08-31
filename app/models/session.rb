class Session < ActiveRecord::Base

  include MyHtml

  DEFAULT_NAME = "To Be Scheduled".freeze

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :portfolio
  belongs_to :chair, :class_name => "Participant"

  fields do
    name       :string, :required, :default => DEFAULT_NAME
    short_name :string
    starts_at  :datetime, :required, :default => '2013-10-26 08:00'
    duration   :integer
    timestamps
  end

  belongs_to :room
  belongs_to :joomla_article

  has_many :presentations
  has_many :involvements, :through => :presentations

  default_scope :order => "starts_at, duration, name"

  validates_uniqueness_of :name, :scope => :portfolio_id
  validates_uniqueness_of :short_name, :scope => :portfolio_id, :allow_nil => true, :allow_blank => true

  def after_update
    return unless single_presentation?
    single = presentations.first
    single.update_attributes(:title => name) unless single.title == name
    single.update_attributes(:short_title => short_name) unless single.short_title == short_name
  end

  def before_save
    self.name = html_encode_non_ascii_characters(name)
  end

  def after_save
    portfolio.changes_pending!
  end

  def after_destroy
    joomla_article.destroy if joomla_article
  end

  def normalize_presentation_positions!
    presentations.each_with_index do |p, i|
      p.position = i + 1
      p.save
    end
    after_save
  end

  def overlaps? rhs
    starts_at > rhs.starts_at ?
      rhs.overlaps?(self) :
      starts_at + duration.minutes > rhs.starts_at
  end

  def <=> rhs
    cmp = if room && rhs.room
	    room.name <=> rhs.room.name
	  elsif room
	    1
	  else
	    -1
	  end
    return cmp unless cmp == 0
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

  def hosting_conference
    portfolio.hosting_conference
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
      "#{time_slot} - #{room_to_html}",
      chair_to_html
    )
  end

  def chair_to_html
    if (chair) 
      div("chair", "Chair: #{chair}")
    end
  end

  def room_to_html
    room ? room.html_link : 'Room TBD'
  end

  def at_a_glance_name
    (short_name || "") =~/\S/ ? short_name : name
  end

  def at_a_glance_html include_portfolio = true
    title = time_slot("").sub(/[ap]m$/,"") + "\n" +  presentations.*.at_a_glance_title.join("\n")
    [
      (portfolio.at_a_glance_html if portfolio && include_portfolio),
      (joomla_article ? internal_link(joomla_article, at_a_glance_name, title) : at_a_glance_name)
    ].compact.join " "
  end

  def populate_joomla_program category, ordering = 1
    unless joomla_article
      self.joomla_article = 
	category.articles.find_by_title(name) ||	# This should not happen
	category.articles.create!(:title => name, :sectionid => category.section)
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
      :fulltext	=> to_html,
      :ordering => ordering
    )
    overview_text = if all_presentations_in_one?
      nil
    else
      li(internal_link(joomla_article, name)) 
    end
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
