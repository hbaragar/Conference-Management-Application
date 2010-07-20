class Presentation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :portfolio

  fields do
    title	:string, :mandatory
    short_title	:string
    abstract	:markdown, :mandatory
    external_reference	:string
    url		:string
    timestamps
  end


  def conference
    portfolio.conference
  end

  def load_from xml
    xml.each do |element|
      string = element.to_s
      text = element.text
      case element.name
      when "title":		self.title = text
      when "shorttitle":	self.short_title = text
      when "abstract":		self.abstract = string
      when "workshop_url":	self.url = text
      else
	logger.info "Presentation::load_from does not handle #{element.name} elements"
      end
    end
    save
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
