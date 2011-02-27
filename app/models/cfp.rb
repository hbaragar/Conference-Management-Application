class Cfp < Call

  validates_presence_of :due_on

  has_many :other_dates, :class_name => "CfpDate", :dependent => :destroy
  has_many :broadcast_emails, :dependent => :destroy
  has_many :external_reviewers, :dependent => :destroy

  def after_create
    other_dates.create(:label => "Notifications", :due_on => due_on + 1.months)
    other_dates.create(:label => "Camera-ready copy due", :due_on => due_on + 2.months)
  end

  def publish_to_joomla
    conference.publish_to_joomla 'Call for Papers'
  end

  def populate_joomla_call_for_papers category, ordering
    if state == 'unpublished'
      joomla_article && joomla_article.destroy
      save
    else
      unless joomla_article
	self.joomla_article = category.articles.create!(:title => name, :sectionid => category.section)
	save
      end
      joomla_article.update_attributes(
	:title		=> name,
        :category	=> category,
        :introtext	=> portfolio_description.to_html,
        :fulltext	=> full_details,
	:ordering	=> ordering
      )
      save
    end
    overview_text = li(internal_link(joomla_article, name))
  end

  def full_details
    div("",
	submission_summary,
	conference_description.to_html,
	details.to_html,
	contact_info,
	committee_members
    )
  end

  def contact_info
    div("",
      h3("For More Information"),
      "<p>",
      "For additional information, clarification, or answers to questions",
      " please contact the #{name} Chair, #{chairs}, at #{email_link}.",
      "</p>"
    )
  end

  def submission_summary
    table({:class => "view cfp-submission-summary", :cellspacing => "0"},
      tr({},
	th({:colspan => 2},"Submission Summary")
      ),
      tr({},
	td({},"Due on:"),
	td({},due_on.strftime("%B %d, %Y"))
      ),
      other_dates.collect do |od|
	tr({},
	  td({},"#{od.label}:"),
	  td({},"#{od.due_on_prefix}#{od.due_on.strftime('%B %d, %Y')}")
	)
      end,
      tr({},
	td({}, "Format:"),
	td({}, external_link(format_url,format_style))
      ),
      if submit_to_url && submit_to_url =~ /\w/
	tr({},
	  td({}, "Submit to:"),
	  td({}, external_link(submit_to_url,submit_to_url))
	)
      end,
      tr({},
	td({}, "Contact:"),
	td({}, email_link(chairs), " (chair)")
      )
    )
  end

  def committee_members
    return "" unless members.count > 0
    div("cfp-committee-members",
      h3({}, "#{portfolio} Committee"),
      ul(
	members.collect do |m|
          li(
	    [
	      m.name.to_html,
	      m.affiliation.to_html,
	      m.country.to_html
	    ].select{|s| s && s[/\w/]}.join(", ") + role_of(m)
	  )
	end
      ),
      if external_reviewers.count > 0 
	div("external-reviewers",
	  h3({}, "External Reviewers"),
	  ul(
	    external_reviewers.collect do |er|
	      li(
		[
		  er.name.to_html,
		  er.affiliation.to_html,
		  er.country.to_html
		].select{|s| s && s[/\w/]}.join(", ")
	      )
	    end
	  )
	)
      end
    )
  end

  def role_of member
    member.chair ? " (chair)" : ""
  end

  # --- Permissions --- #


private

  def initialize *args
    super *args
    self.details = %Q(
### Selection Process
&lt;selection process&gt;

### Submission
&lt;submission format and process&gt;
)
  end

end
