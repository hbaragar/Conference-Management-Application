class Portfolio < ActiveRecord::Base

  require 'rexml/document'
  include REXML

  include MyHtml

  hobo_model # Don't put anything above this


  belongs_to :conference
  attr_readonly :conference_id

  fields do
    name        :string, :required
    public_email_address :email_address
    call_type	enum_string(:no_call, :for_presentations, :for_supporters, :for_next_years), :required, :default => 'no_call'
    session_type enum_string(:no_sessions, :single_presentation, :multiple_presentations, :all_in_one), :required,
      :default => 'no_sessions'
    typical_session_duration :integer, :default => 90
    external_reference_prefix	:string
    presentation_fields :string, :default => "title, short_title, external_reference, abstract"
    description :markdown
  end

  belongs_to :joomla_category
  belongs_to :joomla_menu

  has_many :chairs, :class_name => "Member", :conditions => {:chair => true}
  has_many :members, :dependent => :destroy
  has_many :cfps, :dependent => :destroy	# Really only one, but we want the hobo support

  has_many :sessions, :dependent => :destroy
  has_many :presentations, :dependent => :destroy, :order => :title

  has_many :call_for_supporters, :dependent => :destroy
  has_many :call_for_next_years, :dependent => :destroy

  default_scope :order => :name

  named_scope :with_sessions, :conditions => 'session_type != "no_sessions"'

  def hosting_conference
    conference.hosting_conference
  end

  def before_validation
    self.presentation_fields.sub!(/,+\s*$/, "")
  end

  def validate
    unless (bad = configured_presentation_fields - Presentation.configurable_fields).empty?
      errors.add(:presentation_fields, %Q(#{bad.collect{|f| '"'+f+'"'}.join(', ')} not allowed))
    end
  end

  def before_save
    self.name = html_encode_non_ascii_characters(name)
    self.description = html_encode_non_ascii_characters(description)
  end

  def before_update
    return unless any_changed?(:name, :session_type, :description)
    self.state = 'changes_pending' if state == 'published'
  end

  def chair? user
    not (chairs & user.members).empty?
  end

  def cfp
    cfps.first
  end

  def multiple_presentations_per_session?
    session_type == "multiple_presentations"
  end

  def single_presentation_per_session?
    session_type == "single_presentation"
  end

  def all_presentations_in_one_session?
    session_type == "all_in_one"
  end

  def configured_presentation_fields
    presentation_fields.split(/,\s*/)
  end

  def days
    list = {}
    sessions.each do |s|
      (list[s.starts_at.midnight] ||= []) << s
    end
    list.sort.collect {|date,sessions| Day.new(:date => date, :sessions => sessions)}
  end

  def load_presentation_from source
    xml = Document.new(source).root
    new_or_existing_presentation(xml).load_from xml
  end

  def new_or_existing_presentation xml
    references = {
      :external_reference	=> xml.attributes["id"],
      :title			=> xml.elements["title"].text,
      :short_title		=> xml.elements["shorttitle"].text,
    }
    [:external_reference, :title, :short_title].each do |field|
      value = references[field]
      next unless value && value[/\S/]
      matches = presentations.find(:all, :conditions => {field => value})
      return matches.first if matches.count == 1
    end
    presentations.create!(references)
  end

  def new_or_existing_session single_presentation_session_name = nil
    fields = {
      :name =>  case session_type
		when 'multiple_presentations':	"#{name} (Unscheduled)"
		when 'single_presentation':	single_presentation_session_name
		when 'all_in_one':		name
		else
		  "Miscelaneous"
		end
    }
    sessions.find(:first, :conditions => fields) || sessions.create(fields)
  end

  def publish_to_joomla
    hosting_conference.publish_to_joomla 'Program'
    hosting_conference.publish_to_joomla 'Schedule'
  end

  def populate_joomla_program section, extras
    return if session_type == 'no_sessions'
    ordering = extras[:ordering]
    unless joomla_category
      menu = extras[:menu]
      self.joomla_category = section.categories.create(:title => name)
      self.joomla_menu = menu.items.create(
	:name => name,
	:parent => menu.id,
	:sublevel => 1,
        :link  => JoomlaMenu::link_for(joomla_category)
      )
      save
    end
    joomla_category.update_attributes(:title => name)
    joomla_menu.update_attributes(:name => name, :ordering => ordering)
    joomla_menu.update_params!(:show_section => "1", :pageclass_sfx => "program")
    if session_type == "all_in_one"
      if s = sessions.first
	s.populate_joomla_program(joomla_category)
	overview_text = [h4(internal_link(s.joomla_article, name))]
      end
    else
      overview_text = [
	h4(internal_link(joomla_category, name)),
	ul(sessions.collect{|s| s.populate_joomla_program joomla_category})
      ]
    end
  end

  def populate_joomla_supporters category, extras
    menu = extras[:menu]
    call_for_supporters.each do |c|
      article = c.populate_joomla_supporters category
      menu.items.find_by_name(name) || menu.items.create(
        :name => name,
        :sublevel => 1,
        :link => JoomlaMenu::link_for(article)
      )
    end
    overview_text = li(name)
  end

  def html_schedule
    days.*.html_schedule
  end

  def at_a_glance_html
    span("portfolio", joomla_category ? internal_link(joomla_category, name) : name)
  end


  def <=> rhs
    cmp = conference <=> rhs.conference
    return cmp unless cmp == 0
    name <=> rhs.name
  end

  # --- LifeCycle --- #

  lifecycle do

    state :unpublished, :default => true
    state :published
    state :changes_pending

    transition :changes_pending,{ :published => :changes_pending }
    transition :publish,	{ :unpublished => :published }, :available_to => :all	do
      publish_to_joomla
    end
    transition :push_changes,{ :changes_pending => :published }, :available_to => :all do
      publish_to_joomla
    end
#    transition :unpublish,	{ :published => :unpublished }, :available_to => :all do
#      publish_to_joomla
#    end
#    transition :unpublish,	{ :changes_pending => :unpublished }, :available_to => :all do
#      publish_to_joomla
#    end

  end

  def published?
    lifecycle.published_state?
  end

  def unpublished?
    lifecycle.unpublished_state?
  end

  def changes_pending?
    lifecycle.changes_pending_state?
  end

  def changes_pending!
    self.lifecycle.changes_pending! nil
  end


  # --- Permissions --- #
  
  never_show :joomla_category, :joomla_menu

  def create_permitted?
    return true if acting_user.administrator?
    conference && conference.chair?(acting_user)
  end

  def update_permitted?
    return false if name_changed? && name_was == "General"
    return false if any_changed?(:conference_id) && !acting_user.administrator?
    chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def destroy_permitted?
    return false if name == "General"
    members.empty? && (conference.chair?(acting_user) || acting_user.administrator?)
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
