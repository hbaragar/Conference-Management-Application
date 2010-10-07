class CallForNextYear < Call


  def publish_to_joomla
    conference.publish_to_joomla 'Next Year'
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
        :fulltext	=> details.to_html
      )
    end
    overview_text = nil
  end


  # --- Permissions --- #

  never_show :due_on, :format_style, :format_url, :submit_to_url

end
