class Day

  include MyHtml

  attr_reader :date, :day_sessions, :evening_sessions
  attr_accessor :joomla_category, :joomla_article, :joomla_menu
  
  def initialize attribs
    @date = attribs[:date]
    @day_sessions, @evening_sessions = attribs[:sessions].partition {|s| s.ends_at <= end_of_day}
    @day_sessions.sort!
    @evening_sessions.sort!
  end

  def end_of_day
    date + 18.hours
  end

  def starts_at
    day_sessions.*.starts_at.min
  end

  def ends_at
    day_sessions.*.ends_at.max
  end

  def tick_size
    15.minutes
  end

  def tick_count
    ((ends_at - starts_at) / tick_size).round
  end

  def ncols 
    # includes 2 columns for room names,
    # as well as a column of each evening session
    2 + tick_count + evening_sessions.count
  end

  def name
    "#{day} (#{short_date})"
  end

  def day
    date.strftime('%A')
  end

  def short_date
    date.strftime('%b %d')
  end

  def rooms
    day_sessions.sort do |a,b|
      cmp = a.portfolio <=> b.portfolio 
      cmp = a <=> b if cmp == 0
      cmp
    end.*.room.uniq
  end

  def portfolios
    day_sessions.*.portfolio.uniq.sort
  end

  def populate_joomla_schedule section, extras
    # Kluge: category checked_out_time is not used during the generatation of content,
    #        so co-opt it for sorting purposes (see JoomlaSection::restore_integrity!)
    find_or_create_joomla_category_in section
    find_or_create_joomla_article_in joomla_category
    find_or_create_joomla_menu_in extras[:menu]
    joomla_article.fulltext = html_schedule
    joomla_article.save
    overview_text = tr("",
      td({:class => 'label'}, div("", internal_link(joomla_article, day)), div("date", short_date)),
      td({},
	ul(
	  portfolios.partition{|p| p.conference.hosting? }.collect do |part|
	    part.collect do |portfolio|
	      li(internal_link(portfolio.joomla_category, portfolio.name))
	    end.join("\n")
	  end.compact.join("\n" + li("&nbsp;") + "\n")
	)
      ),
      td({:class => "evening"},
	if evening_sessions.count > 0
	  ul(
	    evening_sessions.collect do |s|
	      li(
		div("",internal_link(s.joomla_article,s.name)),
		div("time-slot",s.time_slot(nil)),
		div("",s.room)
	      )
	    end
	  )
	end
      )
    )		       
  end

  def find_or_create_joomla_category_in section
    self.joomla_category = section.categories.find_by_title('Days') ||
      section.categories.create!(:title => 'Days')
    joomla_category.update_attributes(:alias => nil)
    joomla_category
  end

  def find_or_create_joomla_article_in category
    self.joomla_article = category.articles.find_by_title(name) ||
      category.articles.create!(:title => name, :checked_out_time => date)
    attribs = joomla_article.attribs.clone
    attribs[/show_section=(\d*)/,1] = "0"
    attribs[/show_category=(\d*)/,1] = "0"
    attribs[/show_title=(\d*)/,1] = "0"
    joomla_article.update_attributes(:alias => nil, :attribs => attribs)
    joomla_category
  end

  def find_or_create_joomla_menu_in menu
    joomla_menu = menu.items.find_by_name(name) || menu.items.create(:name => name)
    joomla_menu.update_attributes(
      :checked_out_time	=> date,
      :parent		=> menu.id,
      :sublevel		=> 1,
      :link		=> JoomlaMenu::link_for(joomla_article),
      :alias		=> nil,
      :published	=> true
    )
    joomla_menu
  end

  def html_schedule
    div("at-a-glance",
      h3(name),
      at_a_glance_table
    )
  end

  def at_a_glance_table 
    # Note: the evening events only go on the first row (and they span rows)
    evening_events = at_a_glance_evening_columns
    table({},
      at_a_glance_header,
      rooms.collect {|r| row = at_a_glance_row r, evening_events; evening_events = nil; row},
      at_a_glance_footer
    )
  end

  def at_a_glance_header
    tr({:class => "not-happening"},
      th({:class => "room"}, "Room"),
      at_a_glance_row_part_for(label_pseudo_sessions).join("").gsub(/td/,"th"),
      th({:class => "room"}, "Room"),
      (th({:class => "happening", :colspan => evening_sessions.count}, "Evening") if evening_sessions.count > 0)
    )
  end

  def at_a_glance_row room, evening_events
    label = room ? room.short_name : "TBD"
    tr({:class => "not-happening"},
      th({:class => "room"}, label),
      at_a_glance_row_part_for(sessions_for room),
      th({:class => "room"}, label),
      evening_events
    )
  end

  def at_a_glance_footer
    [
      tr({:class => "bottom"}, td({:colspan => ncols}, "&nbsp;")),
      tr({:class => "calibration"}, [td({:class => "not-happening"},"&nbsp;")] * ncols)
    ]
  end

  def at_a_glance_row_part_for sessions
    tape = ticker_tape_for sessions
    tds = []
    while tape.size > 0
      ncols = 1
      session = tape.shift
      while tape.size > 0 && session == tape.first
	ncols += 1
	tape.shift
      end
      css = {
	:colspan	=> ncols,
	:class		=> (session ? "happening" : "not-happening")
      }
      tds << td(css, session ? session.at_a_glance_html : "&nbsp;")
    end
    tds
  end

  def at_a_glance_evening_columns
    evening_sessions.collect do |s|
      td({:class => "evening happening", :rowspan => rooms.count},
        div("", (s.at_a_glance_html(nil))) + 
	  div("time-slot", s.time_slot(nil)) +
	  div("", s.room_to_html)
      )
    end
  end

  def label_pseudo_sessions
    duration = 90
    start_times = [
      date + 8.hours + 30.minutes,
      date + 10.hours + 30.minutes,
      date + 13.hours + 30.minutes,
      date + 15.hours + 30.minutes
    ]
    start_times.collect do |st|
      et = st + duration.minutes
      name = [st, et].collect{|t| t.strftime('%I:%M').sub(/^0+/,"")}.join("-")
      Session.new(:name => name, :starts_at => st, :duration => duration)
    end.select do |s|
      starts_at <= s.starts_at && s.ends_at <= ends_at
    end
  end

  def sessions_for room
    day_sessions.select{|s| s.room == room}
  end

  def ticker_tape_for sessions
    tape = Array.new(tick_count)
    sessions.reject{|s| s.duration < 30}.each do |s|
      start_tick = ((s.starts_at - starts_at) / tick_size).round
      nticks = (s.duration.minutes / tick_size).round
      tape[start_tick, nticks] = [s] * nticks
    end
    tape
  end

end
