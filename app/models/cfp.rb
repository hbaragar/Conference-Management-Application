class Cfp < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :portfolio
  attr_readonly :portfolio_id

  fields do
    due_on        :date, :required
    format_style  :string, :default => "ACM Proceedings format"
    format_url    :string, :default => "http://www.acm.org/sigs/sigplan/authorInformation.htm"
    submit_to_url :string, :default => "http://cyberchair.acm.org/splash???/submit/"
    details       :text, :default => "To be completed by the portfolio chair"
    timestamps
  end


  belongs_to :joomla_article

  has_many :members, :through => :portfolio
  has_many :other_dates, :class_name => "CfpDate", :dependent => :destroy

  default_scope :order => "due_on"


  def conference
    portfolio && portfolio.conference
  end

  def name
    portfolio.to_s
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
    portfolio.public_email_address
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
    joomla_article.introtext = portfolio.description.to_html
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
      "For additional information, clarification, or questions",
      " please contact the program committee chair, #{chairs}, at #{email_link}."
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

  never_show :joomla_article

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
    %Q(<div #{tag_attributes({:class => css_class})}>#{text.join("")}\n</div>\n)
  end

  def h3(*text)
    return "" unless text
    %Q(<h3>#{text.join("")}\n</h3>\n)
  end

  def ul(*text_list)
    text = text_list.join("")
    "\n<ul>\n#{text}</ul>\n" unless text.empty?
  end

  def ol(*text_list)
    text = text_list.join("")
    "\n<ol>\n#{text}</ol>\n" unless text.empty?
  end

  def li(*text)
    "<li>#{text.join('')}</li>\n"
  end

  def table(attributes,*text)
    "\n<table #{tag_attributes(attributes)}>\n#{text.join('')}\n</table>\n" unless text.empty?
  end

  def tr(attributes,*text)
    %Q(\n<tr #{tag_attributes(attributes)}>\n#{text.join('')}</tr>\n)
  end

  def th(attributes, *text)
    "<th #{tag_attributes(attributes)}>#{text.join('')}</th>\n"
  end

  def td(attributes, *text)
    %Q(<td #{tag_attributes(attributes)}>#{text.join('')}</td>\n)
  end

  def email_link addressees=email_address, address=email_address
    %Q(<a href="mailto:#{address}">#{addressees}</a>)
  end

  def external_link url, text
    %Q(<a href="#{url}" target="_blank">#{text}</a>)
  end

  def tag_attributes attributes
    attributes.collect{|k,v| %Q(#{k}="#{v}")}.join(" ")
  end

end
