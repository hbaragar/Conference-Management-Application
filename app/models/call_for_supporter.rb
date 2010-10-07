class CallForSupporter < Call

  has_many :supporter_levels, :dependent => :destroy


  def publish_to_joomla
    conference.publish_to_joomla 'Supporters'
  end

  def populate_joomla_supporters joomla_category
    if state == 'unpublished'
      joomla_article.update_attributes(:state => 0) if joomla_article
    else
      unless joomla_article
	self.joomla_article = joomla_category.articles.create(
	  :title 	=> name,
	  :section	=> joomla_category.joomla_section
	)
	save
      end
      joomla_article.update_attributes(
	:title		=> name,
        :alias		=> nil,
        :section	=> joomla_category.joomla_section,
        :introtext	=> portfolio_description.to_html,
        :fulltext	=> full_details
      )
    end
    overview_text = nil
  end

  def full_details
    div("",
	supporter_levels_summary,
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
	  td({:class => "description"},sl.description.to_html)
	)
      end
    )
  end


  # --- Permissions --- #

  never_show :due_on, :format_style, :format_url, :submit_to_url

end
