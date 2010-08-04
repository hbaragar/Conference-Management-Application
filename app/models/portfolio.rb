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
    call_type	enum_string(:no_call, :for_presentations, :for_supporters), :required, :default => 'no_call'
    session_type enum_string(:no_sessions, :single_presentation, :multiple_presentations, :all_in_one), :required,
      :default => 'no_sessions'
    typical_session_duration :integer, :default => 90
    external_reference_prefix	:string
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

  def chair? user
    not (chairs & user.members).empty?
  end

  def cfp
    cfps.first
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

  def populate_joomla_program section, menu
    return if session_type == 'no_sessions'
    if joomla_category
      joomla_category.update_attributes(:title => name)
      joomla_menu.update_attributes(:name => name)
    else
      self.joomla_category = section.categories.create(:title => name)
      self.joomla_menu = menu.items.create(
	:name => name,
	:parent => menu.id,
	:sublevel => 1,
        :link  => JoomlaMenu::link_for(joomla_category)
      )
      save
    end
    params = joomla_menu.params.clone
    params[/show_section=(\d*)/,1] = "1"
    joomla_menu.update_attributes!(:params => params)
    overview_text = [
      h4(internal_link(joomla_category, name)),
	ul(sessions.collect{|s| s.populate_joomla_program joomla_category})
    ]
  end


  def populate_joomla_supporters category, menu
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
