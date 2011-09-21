class Participant < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :conference

  fields do
    name                  :html_string, :required
    conflicted            :boolean
    private_email_address :email_address
    affiliation           :html_string
    country		  :html_string
    bio                   :markdown
    timestamps
  end

  has_many :involvements, :dependent => :destroy
  has_many :presentations, :through => :involvements

  def portfolios
    presentations.*.portfolio
  end

  default_scope :order => "name, id DESC"

  validates_presence_of :conference_id
  validates_uniqueness_of :name, :scope => :conference_id

  def validate
    errors.add(:conference_id, "must be a hosting conference") unless
      conference && conference.hosting?
  end

  def before_save
    self.name = html_encode_non_ascii_characters(name)
    self.affiliation = html_encode_non_ascii_characters(affiliation)
    self.country = html_encode_non_ascii_characters(country)
  end

  def after_save
    portfolios.*.changes_pending!
  end

  def sessions
    presentations.*.session.sort
  end

  def set_conflicted!
    self.conflicted = session_conflicts.count > 0
    save
  end

  def conflicting_sessions
    session_conflicts.collect do |conflict|
      conflict.collect {|s| "#{s.name} @ #{s.time_slot}" }.join " vs "
    end
  end

  def session_conflicts
    conflicts = []
    unique_sessions = sessions.uniq
    previous = unique_sessions.shift
    unique_sessions.each do |s|
      conflicts << [previous, s] if s.overlaps? previous
      previous = s
    end
    conflicts
  end

  def <=> rhs
    name <=> rhs.name
  end


  def to_html
    [
      span("name", name.to_html),
      span("affiliation",(affiliation||"").to_html),
      span("country", (country||"").to_html)
    ].grep(/\S/).join(", ")
  end

  # --- Permissions --- #

  never_show :bio

  def create_permitted?
    acting_user.administrator? || acting_user.portfolio_chair?
  end

  def update_permitted?
    return false if conference_id_changed?
    acting_user.administrator? || acting_user.portfolio_chair?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.portfolio_chair?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
