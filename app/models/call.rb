class Call < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :portfolio
  attr_readonly :portfolio_id

  fields do
    due_on        :date
    format_style  :string, :default => "ACM Proceedings format"
    format_url    :url, :default => "http://www.acm.org/sigs/sigplan/authorInformation.htm"
    submit_to_url :url, :default => ""
    details       :markdown
    timestamps
  end


  belongs_to :joomla_article

  has_many :members, :through => :portfolio

  def before_save
    self.details = html_encode_non_ascii_characters(details)
  end

  def before_update
    return if only_changed? :state, :joomla_article_id
    self.state = 'changes_pending' if state == 'published'
  end


  def name
    portfolio.to_s
  end

  def portfolio_description
    portfolio.description
  end

  def conference
    portfolio.conference
  end

  def conference_description
    conference.description
  end

  def chairs
    portfolio.chairs.join(" and ")
  end

  def email_address
    portfolio.public_email_address
  end

  def <=> other
    if (cmp = due_on <=> other.due_on) != 0
      cmp
    else
      portfolio.position <=> other.portfolio.position
    end
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
    transition :unpublish,	{ :published => :unpublished }, :available_to => :all do
      publish_to_joomla
    end
    transition :unpublish,	{ :changes_pending => :unpublished }, :available_to => :all do
      publish_to_joomla
    end

  end

  #  delegate :changes_pending!, :publish!, :unpublish!, :to => :lifecycle

  def changes_pending!
    self.lifecycle.changes_pending! nil
  end

  # --- Permissions --- #

  never_show :joomla_article

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
