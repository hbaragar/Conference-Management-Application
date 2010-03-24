class CallForSupporter < Call

  has_many :supporter_levels, :dependent => :destroy


  def publish
    super.publish
    conference.publish 'general_information'
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

  never_show :due_on, :format_style, :format_url, :submit_to_url

end
