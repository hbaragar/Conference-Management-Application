class CallForSupporter < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :portfolio
  attr_readonly :portfolio_id

  fields do
    details :markdown
    timestamps
  end

  belongs_to :joomla_article

  has_many :supporter_levels, :dependent => :destroy


  def name
    portfolio.name
  end

  def conference
    portfolio && portfolio.conference
  end

  def conference_description
    conference.description
  end

  def portfolio_description
    portfolio.description
  end

  def generate_joomla_article joomla_category
    unless joomla_article
      self.joomla_article = joomla_category.articles.create(
	:title 	 => name,
	:section => joomla_category.joomla_section
      )
      save
    end
    joomla_article.introtext = portfolio_description.to_html
    joomla_article.fulltext = full_details
    joomla_article.save
  end

  def full_details
    div("",
	supporter_levels_summary,
	conference_description.to_html,
	details.to_html
    )
  end

  def supporter_levels_summary
    table({:class => "view supporter-level-summary"},
      tr({},
	th({}, "Donation & Level"),
	th({}, "Benefits")
      ),
      supporter_levels.collect do |sl|
	tr({},
	  td({:class=>"level"},
	    div("minimum_donation", sl.minimum_donation, " (USD)"),
	    div("name", sl.name)
	  ),
	  td({:class => "description"},sl.description)
	)
      end
    )
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
