class Room < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  fields do
    name       :string
    conflicted :boolean
    capacity   :string
    door_count :integer
    short_name :string
    timestamps
  end

  belongs_to :facility_area

  has_many :sessions
  has_many :portfolios, :through => :sessions

  default_scope :order => :name

  validates_uniqueness_of :name, :scope => :facility_area_id

  def to_s
    name
  end

  def <=> rhs
    cmp = facility_area.name <=> rhs.facility_area.name
    return cmp unless cmp == 0
    name <=> rhs.name
  end


  def before_save
    self.name = html_encode_non_ascii_characters(name)
  end

  def after_save
    portfolios.*.changes_pending!
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

  def html_link
    internal_link(
      facility_area.joomla_article,
      name,
      [short_name, facility_area.name].join(" - ")
    )
  end

  def short_link
    internal_link(
      facility_area.joomla_article,
      short_name,
      [name, facility_area.name].join(" - ")
    )
  end


  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || chair?(acting_user)
  end

  def update_permitted?
    acting_user.administrator? || chair?(acting_user)
  end

  def destroy_permitted?
    acting_user.administrator? || chair?(acting_user)
  end

  def view_permitted?(field)
    true
  end

end
