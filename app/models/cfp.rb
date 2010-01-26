class Cfp < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :portfolio

  fields do
    due_on        :date, :required
    format_style  :string, :default => "ACM Proceedings format"
    format_url    :string, :default => "http://www.acm.org/sigs/sigplan/authorInformation.htm"
    submit_to_url :string, :default => "http://cyberchair.acm.org/splash???/submit/"
    details       :text, :default => "To be completed by the portfolio chair"
    timestamps
  end


  def conference
    portfolio && portfolio.conference
  end

  def name
    "#{portfolio} CFP"
  end

  def portfolio_description
    portfolio.description
  end

  def conference_description
    conference.description
  end

  def chairs
    portfolio.chairs.join(" and ")
  end

  def email_address
    portfolio.email_address
  end

  def contact_info
    div({:class => "view cfp-submission-summary"},
      "For additional information, clarification, or questions",
      " please contact the program committee chair, ",
      "#{chairs} at #{email_link}."
    )
  end

  def submission_summary
    #chairs = portfolio.chairs.collect{|m|
    table({:class => "view cfp-submission-summary"},
      tr({},
	th({:colspan => 2},"Submission Summary")
      ),
      tr({},
	td({},"Due on:"),
	td({},due_on)
      ),
      tr({},
	td({}, "Format:"),
	td({}, external_link(format_url,format_style))
      ),
      tr({},
	td({}, "Submit to:"),
	td({}, external_link(submit_to_url,submit_to_url))
      ),
      tr({},
	td({}, "Contact:"),
	td({}, email_link(chairs), " (chair)")
      )
    )
  end

  # --- Permissions --- #

  attr_readonly :portfolio_id

  def create_permitted?
    return true if acting_user.administrator?
    portfolio && (portfolio.chair?(acting_user) || conference.chair?(acting_user))
  end

  def update_permitted?
    return true if acting_user.administrator?
    none_changed?(:portfolio_id) && (portfolio.chair?(acting_user) || conference.chair?(acting_user))
  end

  def destroy_permitted?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

protected

  def div(css_class, *text)
    return "" unless text
    %Q(<div class="#{css_class}">#{text.join("")}\n</div>\n)
  end

  def table(css_attributes,*text)
    "\n<table #{attributes(css_attributes)}>\n#{text.join('')}\n</table>\n" unless text.empty?
  end

  def tr(css_attributes,*text)
    %Q(\n<tr #{attributes(css_attributes)}>\n#{text.join('')}</tr>\n)
  end

  def th(css_attributes, *text)
    "<th #{attributes(css_attributes)}>#{text.join('')}</th>\n"
  end

  def td(css_attributes, *text)
    %Q(<td #{attributes(css_attributes)}>#{text.join('')}</td>\n)
  end

  def email_link addressees=email_address, address=email_address
    %Q(<a href="mailto:#{address}">#{addressees}</a>)
  end

  def external_link url, text
    %Q(<a href="#{url}" target="_blank">#{text}</a>)
  end

  def attributes css_attributes
    css_attributes.collect{|k,v| %Q(#{k}="#{v}")}.join(" ")
  end

end
