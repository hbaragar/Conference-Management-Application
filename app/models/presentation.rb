class Presentation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :portfolio
  belongs_to :session

  fields do
    title	:string, :required
    short_title	:string
    abstract	:markdown
    external_reference	:string
    url		:string
    timestamps
  end


  has_many :involvements, :dependent => :destroy
  has_many :participants, :through => :involvements


  def conference
    portfolio.conference
  end

  def load_from xml
    involvements.destroy_all
    xml.elements.each do |element|
      string = element.to_s
      text = element.text
      case element.name
      when "title":		self.title = text
      when "shorttitle":	self.short_title = text
      when "abstract":		self.abstract = string
      when "author":		self.involvements.create(
				  :role => 'author',
				  :participant =>  new_or_existing_participant(element)
				)
      when "workshop_url":	self.url = text
      #when "registration_id"]
      #when "tutclass"]
      #when "objectives"]
      #when "format"]
      #when "tutaudience"]
      #when "tutresume"]
      else
	logger.info "Presentation::load_from does not handle #{element.name} elements"
      end
    end
    self.session ||= portfolio.new_or_existing_session title
    save
    self
  end


  def new_or_existing_participant xml
    data = {
      :private_email_address	=> xml.elements["email"].text,
      :name			=> xml.elements["name"].text,
      :affiliation		=> xml.elements["affiliation"].text,
      :bio			=> xml.elements["bio"] && xml.elements["bio"].text,
    }
    [:private_email_address, :name].each do |field|
      value = data[field]
      next unless value && value[/\S/]
      matches = Participant.find(:all, :conditions => {field => value})
      return matches.first if matches.count == 1
    end
    Participant.create(data)
  end

  # --- Permissions --- #

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
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
