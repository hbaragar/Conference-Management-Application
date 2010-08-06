class Participant < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :conference

  fields do
    name                  :string, :required, :unique
    conflicted            :boolean
    affiliation           :string
    private_email_address :email_address
    country		  :string
    bio                   :markdown
    timestamps
  end

  has_many :involvements, :dependent => :destroy
  has_many :presentations, :through => :involvements

  default_scope :order => :name

  validates_presence_of :conference_id

  def sessions
    presentations.collect{|p| p.session}.sort
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


  def to_html
    [span("name", name), span("affiliation",affiliation), span("country", country)].grep(/\S/).join(", ")
  end

  # --- Permissions --- #

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
