class Conference < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :colocated_with, :class_name => "Conference"

  fields do
    name        :string, :required
    description :markdown
  end

  belongs_to :joomla_cfp_section, :class_name => "JosSection"

  has_many :colocated_conferences, :class_name => "Conference", :foreign_key => :colocated_with_id
  has_many :portfolios, :dependent => :destroy
  has_many :cfps, :through => :portfolios
  has_many :members, :through => :portfolios

  named_scope :host_conferences, :conditions => {:colocated_with_id => nil}

  def after_create 
    portfolios << Portfolio.new(:name => "General")
  end

  def chair? user
    (members & user.members).select do |m|
      m.portfolio.name == "General" && m.chair
    end.count > 0
  end

  def publish_cfp
    self.joomla_cfp_section ||= JosSection.create(:title => "Call for Papers", :alias => "cfp")
    cfps.each do |c|
      c.publish
      joomla_cfp_section.articles << c.joomla_article
    end
    joomla_cfp_section.count = cfps.count
    joomla_cfp_section.save
    save
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    (chair?(acting_user) && none_changed?(:colocated_with_id)) || acting_user.administrator? 
  end

  def destroy_permitted?
    portfolios.empty? && acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
