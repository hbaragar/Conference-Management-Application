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

  def before_save
    self.name = html_encode_non_ascii_characters(name)
    self.description = html_encode_non_ascii_characters(description)
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

  def presentation_field_view_not_permitted? field
    field = field.to_s
    return false unless Presentation.column_names.include?(field)
    !presentation_fields.split(/,\s*/).include?(field)
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


  # --- Permissions --- #
  
  never_show :joomla_category, :joomla_menu

  def create_permitted?
    return true if acting_user.administrator?
    conference && conference.chair?(acting_user)
  end

  def update_permitted?
    return false if name_changed? && name_was == "General"
    return false if any_changed?(:conference_id, :presentation_fields) && !acting_user.administrator?
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
