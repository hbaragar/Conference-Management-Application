class Cfp < Call


  has_many :other_dates, :class_name => "CfpDate", :dependent => :destroy
  has_many :broadcast_emails, :dependent => :destroy

  default_scope :order => "due_on"

  def after_create
    other_dates.create(:label => "Notifications", :due_on => due_on + 1.months)
    other_dates.create(:label => "Camera-ready copy due", :due_on => due_on + 2.months)
  end


  def joomla_section
    conference.joomla_cfp_section
  end

  def joomla_category
    title = "Due #{due_on.strftime('%B %d, %Y')}"
    categories = joomla_section.categories
    categories.find_by_title(title) || categories.create!(:title => title)
  end

  def generate_joomla_article
    unless joomla_article
      self.joomla_article = joomla_section.articles.create(:title => name)
      save
    end
    joomla_article.category = joomla_category
    joomla_article.introtext = portfolio_description.to_html
    joomla_article.fulltext = full_details
    joomla_article.save
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
    div("view cfp-submission-summary",
      h3("For More Information"),
      "For additional information, clarification, or answers to questions",
      " please contact the #{name} Chair, #{chairs}, at #{email_link}."
    )
  end

  def submission_summary
    table({:class => "view cfp-submission-summary"},
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
	    [m.name, m.affiliation, m.country].select{|s| s && s[/\w/]}.join(", ") + role_of(m)
	  )
	end
      )
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
