class Presentation < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :portfolio
  belongs_to :session

  fields do
    title              :string, :required
    short_title        :string
    external_reference :string
    url                :string
    reg_number         :string
    class_type         :string
    class_format       :string
    audience_types     :string
    abstract           :markdown
    objectives         :markdown
    resume             :markdown
    timestamps
  end


  has_many :involvements, :dependent => :destroy
  has_many :participants, :through => :involvements

  def after_create
    self.session ||= portfolio.new_or_existing_session title
    save
  end

  def after_update
    return unless session.single_presentation?
    session.update_attributes(:name => title) unless session.name == title
  end

  def conference
    portfolio.conference
  end

  def essential_fields
    %w(title short_title external_reference abstract)
  end

  def extra_fields
    portfolio.presentation_fields.split(/,\s*/) - essential_fields
  end

  def load_from xml
    involvements.destroy_all
    xml.elements.each do |element|
      text = element.text.strip rescue ""
      case element.name
      when "title":		self.title = text
      when "shorttitle":	self.short_title = text
      when "abstract":		self.abstract = text
      when "author":		self.involvements.create(
				  :role => 'author',
				  :participant =>  new_or_existing_participant(element)
				)
      when "workshop_url":	self.url = text
      when "tutclass":		self.class_type = text
      when "format":		self.class_format = text
      when "tutaudience":	self.audience_types = text
      when "tutresume":		self.resume = text
      when "objectives":	self.objectives = text
      else
	logger.info "Presentation::load_from does not handle #{element.name} elements"
      end
    end
    save
    self
  end

  def new_or_existing_participant xml
    fields = {}
    xml.elements.each do |element|
      text = element.text.strip
      case element.name
      when "name":		fields[:name] = text
      when "email":		fields[:private_email_address] = text
      when "affiliation":	fields[:affiliation] = text
      when "country":		fields[:country] = text
      when "bio":		fields[:bio] = text
      else
	logger.info "Presentation::load_from does not handle author.#{element.name} elements"
      end
    end
    [:private_email_address, :name].each do |field|
      value = fields[field]
      next unless value && value[/\S/]
      matches = Participant.find(:all, :conditions => {field => value})
      if matches.count == 1
	existing = matches.first
	existing.update_attributes(fields) or next
	return existing
      end
    end
    conference.hosting_conference.participants.create(fields)
  end


  def intro_html
    if session.single_presentation?
      div("participants",participants_to_html)
    else
      li(title_to_html,
	div("participants",participants_to_html)
      )
    end
  end

  def to_html
    div("presentation",
      title_to_html,
      participants_to_html,
      abstract.to_html,
      extra_fields.collect do |field|
        label = field.humanize
	value = self.method(field).call
	div({},
	  case value
	  when HoboFields::MarkdownString: [h5(label), value.to_html]
	  when String: [span("label", label+": "), span("", value)]
	  end
        )
      end
    )
  end

  def title_to_html
    div("title", title) unless session.single_presentation?
  end

  def participants_to_html
    div("participants",
      involvements.collect{|i| i.to_html}
    )
  end


  def session_options
    portfolio.sessions.collect { |s| [s.name, s.id] }.sort
  end


  # --- Permissions --- #

  def create_permitted?
    return true if acting_user.administrator?
    return false unless portfolio
    portfolio.chair?(acting_user) || conference.chair?(acting_user)
  end

  def update_permitted?
    return false if portfolio_id_changed?
    return false if session_id_changed? && !portfolio.multiple_presentations_per_session?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def destroy_permitted?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    return false if portfolio && portfolio.presentation_field_view_not_permitted?(field)
    acting_user.signed_up?
  end

end
